class SirItem < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd
  include Filterable

  belongs_to :sir_log,     -> { readonly }, inverse_of: :sir_items
  belongs_to :group,       -> { readonly }
  belongs_to :cfr_record,  -> { readonly }
  belongs_to :phase_code,  -> { readonly }
  has_many   :sir_entries, -> { log_order }, inverse_of: :sir_item, dependent: :destroy

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
    inclusion: { in: 0..( SIR_ITEM_STATUS_LABELS.size - 1 )}

  SIR_ITEM_CATEGORY_LABELS = SirItem.human_attribute_name( :categories ).freeze

  validates :category,
    inclusion: { in: 0..( SIR_ITEM_CATEGORY_LABELS.size - 1 )}  

  validate :archive_closed_only

  set_trimmed :label, :reference

  # normal scope: do not show archived items

  scope :active, -> { where archived: false }

  # define scopes for filters

  scope :ff_seqno,    ->( s ){ where seqno: s }
  scope :ff_ref,      ->( r ){ where 'reference LIKE :param', param: "%#{ r }%" }
  scope :ff_desc,     ->( t ){ where 'label LIKE :param OR description LIKE :param', param: "%#{ t }%" }
  scope :ff_stts,     ->( s ){ where status: s }
  scope :ff_cat,      ->( c ){ where category: c }

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

  # two helpers for the views...

  # determine depth for display using group_stack

  def self.depth( group_stack, this_entry )
    if this_entry.rec_type == 0
      group_stack.push( this_entry.group_id )
    elsif this_entry.rec_type == 2
      group_stack.pop
    end
    group_stack.length - 1
  end

  def new_sir_entry( rt )
    url_options = { action: :new, controller: :sir_entries, sir_item_id: id, rec_type: rt }
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
