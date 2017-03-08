class SirEntry < ActiveRecord::Base
  include ApplicationModel

  belongs_to :sir_item, inverse_of: :sir_entries
  belongs_to :resp_group, ->{ readonly }, class_name: 'Group'
  belongs_to :orig_group, ->{ readonly }, class_name: 'Group'

  before_destroy  :check_before_destroy
  before_update   :check_before_update
  before_save     :set_defaults
  after_save      :update_item
  after_destroy   :release_item

  validates :sir_item,
    presence: true

  # IMPORTANT: Originating Group for (0) Forward and (2) Response entries
  # is the group preparing the entry, the Responsible Group is the group
  # to which the responsibility to prepare the next entry is passed to.
  #
  # For Comments, responsibility does not change, hence the Responsible
  # Group must remain the same. If Responsible Group and Originating
  # Group is identical, this causes no problem. However, if a comment is
  # addressed to some other group, the addressed group must be stored in
  # as Originator group, and the currently responsible group (writing the
  # comment) must be stored as Responsible Group.
  #
  # The reason is that the Responsible Group for the SIR Item is retrieved
  # from the last SIR Entry - and for simplicity of the retrieval - no
  # difference is made for comments and other record types.

  validates :orig_group,
    presence: true, if: Proc.new{ |me| me.rec_type != 1 || me.orig_group_id.present? }

  validates :resp_group,
    presence: true

  SIR_ENTRY_REC_TYPE_LABELS = SirEntry.human_attribute_name( :rec_types ).freeze

  validates :rec_type,
    presence: true,
    inclusion: { in: 0..2 }

  validates :due_date,
    date_field: { presence: false }

  validate :different_groups
  validate :validate_new_entry, on: :create

  # the following attribute is used when creating views of all entries

  attr_accessor :visibility

  # scopes

  scope :log_order, ->{ reorder( created_at: :asc  )}
  scope :rev_order, ->{ reorder( created_at: :desc )}

  def is_comment?
    rec_type == 1
  end

  # provide access to labels

  def rec_type_label
    SIR_ENTRY_REC_TYPE_LABELS[ rec_type ] unless rec_type.nil?
  end

  def resp_group_code
    ( resp_group.try :code ) || some_id( resp_group_id )
  end

  def orig_group_code
    ( orig_group.try :code ) || some_id( orig_group_id )
  end

  # make sure resp and orig groups are different unless it is a comment

  def different_groups
    return if resp_group_id.nil? || orig_group_id.nil?
    errors.add( :base, I18n.t( 'sir_entries.msg.bad_grp_combo' )) \
      unless resp_group_id != orig_group_id || is_comment?
  end

  # can only destroy entry if it is a comment or the last entry in a thread

  def check_before_destroy
    unless is_comment? || sir_item.sir_entries.last.id == id
      errors.add( :base, I18n.t( 'sir_items.msg.bad_del_req' ))
      return false # throw :abort in Rails 5
    else
      return true
    end
  end

  # permit update only on last item

  def updatable?
    sir_item.sir_entries.last.id == id
  end

  def check_before_update
    unless updatable?
      errors.add( :base, I18n.t( 'sir_items.msg.bad_upd_req' ))
      return false # throw :abort in Rails 5
    else
      return true
    end
  end

  # entry is defined as visible if it has a visibility flag of > 0

  def is_visible?
    visibility && ( visibility > 0 )
  end

  private

    def validate_new_entry
      set_defaults
      sir_item.validate_new_entry( self ) unless sir_item_id.nil?
    end

    def update_item
      sir_item.status = 1
    end

    def release_item
      sir_item.status = nil
    end

    def set_defaults
      set_nil_default( :orig_group_id, resp_group_id )
    end

end
