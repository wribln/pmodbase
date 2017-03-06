class SirItem < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd
  include Filterable

  belongs_to :sir_log,     -> { readonly }, inverse_of: :sir_items
  belongs_to :group,       -> { readonly }
  belongs_to :cfr_record,  -> { readonly }
  belongs_to :phase_code,  -> { readonly }
  has_many   :sir_entries, -> { log_order }, inverse_of: :sir_item, dependent: :destroy
  has_one    :last_entry,  -> { rev_order }, inverse_of: :sir_item, class_name: 'SirEntry'

  before_save :set_defaults

  validates :sir_log,
    presence: true

  validates :group,
    presence: true

  validates :seqno,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :sir_log_id, message: I18n.t( 'sir_items.msg.bad_seqno' )},
    on: :update

  validates :label,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :reference,
    length: { maximum: MAX_LENGTH_OF_NOTE }

  SIR_ITEM_STATUS_LABELS = SirItem.human_attribute_name( :states ).freeze

  validates :status,
    presence: true,
    inclusion: { in: 0..( SIR_ITEM_STATUS_LABELS.size - 1 )}

  SIR_ITEM_CATEGORY_LABELS = SirItem.human_attribute_name( :categories ).freeze

  validates :category,
    inclusion: { in: 0..( SIR_ITEM_CATEGORY_LABELS.size - 1 )}  

  validate :attr_modifications, on: :update

  validate :archive_closed_only

  set_trimmed :label, :reference

  # normal scope: do not show archived items

  scope :active,   -> { where archived: false }

  # define scopes for filters

  scope :ff_seqno,    ->( s ){ where seqno: s }
  scope :ff_ref,      ->( r ){ where 'reference LIKE :param', param: "%#{ r }%" }
  scope :ff_desc,     ->( t ){ where 'label LIKE :param OR description LIKE :param', param: "%#{ t }%" }
  scope :ff_stts,     ->( s ){ where status: s }
  scope :ff_cat,      ->( c ){ where category: c }
  scope :ff_phs,      ->( p ){ where phase_code_id: p }
  scope :ff_grp,      ->( g ){ where group_id: g }
  scope :ff_cgrp,     ->( g ){ includes( :last_entry ).where( 'sir_entries.group_id = :param OR ( sir_entries.group_id IS NULL AND sir_items.group_id = :param )', param: g ).references( :sir_entries )}

  # provide access to labels

  def status_label
    SIR_ITEM_STATUS_LABELS[ status ] unless status.nil?
  end

  def category_label
    SIR_ITEM_CATEGORY_LABELS[ category ] unless category.nil?
  end

  # provide codes for item, group, phase code

  def item_code
    sir_log.item_code( seqno ) unless sir_log_id.nil?
  end

  def group_code
    ( group.try :code ) || some_id( group_id )
  end

  def phase_code_code
    ( phase_code.try :code ) || some_id( phase_code_id )
  end

  # remember previous value of group id for validation

  def group_id=( g )
    @prev_group_id ||= group_id
    self[ :group_id ] = g
  end

  # allow modification of group_id only if no entries exist yet for this item;
  # transition to status new is not permitted if there are entries

  def attr_modifications
    errors.add( :group_id, I18n.t( 'sir_items.msg.bad_grp_chg' )) \
      unless sir_entries.empty? || ( @prev_group_id == group_id ) || @prev_group_id.nil?
    errors.add( :status, I18n.t( 'sir_items.msg.bad_status' )) \
      unless status != 0 || sir_entries.empty?
  end

  # prepare code for responsible party (for index)

  def resp_group_code
    g = ( last_entry.nil? ? group : last_entry.group )
    ( g.try :code ) || some_id( g )
  end

  # set seqno 

  def set_seqno
    self.seqno = sir_log.next_seqno_for_item
  end

  # is the item still open?

  def status_open?
    status < 3
  end

  # allow to set archive status only on closed items

  def archive_closed_only
    if archived and status_open? then
      errors.add( :archived, I18n.t( 'sir_items.msg.bad_archive' ))
    end
  end

  # create stack of group_ids

  def group_stack
    grp_stack = [ group_id ]
    sir_entries.each do |se|
      if se.rec_type == 0
        grp_stack.push( se.group_id )
      elsif se.rec_type == 2
        grp_stack.pop
      end
    end
    grp_stack
  end

  # determine depth for display using group_stack
  # update using new_entry before returning depth

  def self.depth!( grp_stack, new_entry )
    if new_entry.rec_type == 0
      grp_stack.push( new_entry.group_id )
    elsif new_entry.rec_type == 2
      grp_stack.pop
    end
    grp_stack.length - 1
  end

  def self.depth( grp_stack )
    grp_stack.length - 1
  end

  # set visibility for all existing entries (new entries should alway
  # be visible by default!);
  # groups is an array of group_ids for which entries should be shown,
  # blank if all groups have access, nil for no groups;
  # an entry is permitted to be shown, if it belongs to a permitted
  # group or if it is referring to an entry of a permitted group

  def set_visibility( groups, entries = sir_entries )
    if groups.nil?
      entries.each{ |se| se.visibility = 0 }
    elsif groups.empty?
      entries.each{ |se| se.visibility = 1 }
    else
      se_stack = Array.new
      next_visible = groups.include?( group_id ) ? 2 : 0
      entries.each do |se|
        case se.rec_type
        when 0 # forward
          se_stack.push( se )
          if groups.include?( se.group_id )
            se_stack.each{ |sse| sse.visibility = 1 }
            next_visible = 2
          else
            se.visibility = next_visible
            next_visible = 0
          end
        when 1 # comment
          se.visibility = groups.include?( se.group_id ) ? 3 : 0
        when 2 # backward
          se.visibility = se_stack.pop.visibility
          next_visible = groups.include?( se.group_id ) ? 1 : 0
        end
      end
    end
  end

  # this method is to be used to validate all entries belonging to
  # this item's log, method returns with error code or zero:
  # (0) no error, all tests passed
  # (1) forward to previous group
  # (2) comment is not from current group
  # (3) response by SIR Item Owner
  # (4) response not to previous group
  # (5) invalid rec_type

  def validate_entries
    group_stack = [ group_id ]
    sir_entries.each do |se|
      next if se.id.nil? # ignore entries in association proxies
      case se.rec_type
      when 0
        # forward must be to group other than previous groups
        return 1 if group_stack.include?( se.group_id )
        group_stack.push( se.group_id )
      when 1
        # comment must be from current group
        return 2 unless group_stack.last == se.group_id
      when 2
        # response must be to previous group
        group_stack.pop
        return 3 if group_stack.empty?
        return 4 unless group_stack.last == se.group_id
      else
        return 5
      end # case
    end # do
    return 0
  end

  # use this method to ensure that the new SIR Entry is
  # consistent to the current, consistent list of SIR Entries

  def validate_new_entry( new_entry )
    group_stack = [ group_id ]
    sir_entries.each do |se|
      next if se.id.nil?
      case se.rec_type
      when 0
        group_stack.push( se.group_id )
      when 2
        group_stack.pop
      end
    end
    case new_entry.rec_type
    when 0
      new_entry.errors.add( :base, I18n.t( 'sir_items.msg.bad_grp_seq' )) \
        if group_stack.include?( new_entry.group_id )
    when 1
      new_entry.errors.add( :base, I18n.t( 'sir_items.msg.bad_grp_com' )) \
        unless group_stack.last == new_entry.group_id
    when 2
      if group_stack.size < 2
        new_entry.errors.add( :base, I18n.t( 'sir_items.msg.bad_grp_re1' ))
      elsif group_stack[ -2 ] != new_entry.group_id
        new_entry.errors.add( :base, I18n.t( 'sir_items.msg.bad_grp_re2' ))
      end
    end
  end

  private

    # ensure that archived is either true or false, never nil

    def set_defaults
      set_nil_default( :archived, false )
      set_nil_default( :status, 0 )
      set_nil_default( :category, 0 )
    end

end
