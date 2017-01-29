class SirItem < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd
  include Filterable

  belongs_to :sir_log,    -> { readonly }, inverse_of: :sir_items
  belongs_to :group,      -> { readonly }
  belongs_to :cfr_record, -> { readonly }
  belongs_to :phase_code, -> { readonly }
  has_many   :sir_entries,                 inverse_of: :sir_item, dependent: :destroy

  before_save :set_defaults

  validates :sir_log,
    presence: true

  validates :group,
    presence: true

  validates :seqno,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :sir_log_id, message: I18n.t( 'sir_items.msg.bad_seqno' )}

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

  # this method is to be used to validate all entries belonging to
  # this item's log



  # this method is to be used to validate the new/modified entry and ensure
  # that it fits consistently into this item's log:
  #
  # (a) request to new entry's group must not refer to another entry's group
  #     already on path (back to item)
  
  def consistent?( se_n )
    se_i = se_n
    until se_i.parent_id.nil? do
      se_i = se_i.parent
      if se_i.group_id == se_n.group_id
        errors.add( :parent_id, I18n.t( 'sir_items.msg.bad_link' ))
        return
      end
      raise RunTimeError, 'loop in SIR Log entries' if se_i.id == se_n.id
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