class TiaItem < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd
  include Filterable
   
  belongs_to :tia_list,     -> { readonly }, inverse_of: :tia_items
  belongs_to :account,      -> { readonly }, inverse_of: :tia_items
  has_many   :tia_item_deltas,               inverse_of: :tia_item, dependent: :destroy

  before_save :set_defaults

  validates :seqno,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :tia_list_id, message: I18n.t( 'tia_items.msg.bad_seqno' )}

  validates :description,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  validates :comment,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  TIA_ITEM_PRIO_LABELS = TiaItem.human_attribute_name( :priorities ).freeze

  validates :prio,
    inclusion: { in: 0..( TIA_ITEM_PRIO_LABELS.size - 1 )}

  TIA_ITEM_STATUS_LABELS = TiaItem.human_attribute_name( :states ).freeze

  validates :status,
    inclusion: { in: 0..( TIA_ITEM_STATUS_LABELS.size - 1 )}

  validates :account,
    presence: true, if: Proc.new{ |me| me.account_id.present? }

  validates :tia_list,
    presence: true

  validates :due_date,
    date_field: { presence: false }

  validate :archive_closed_only

  # normal scope: do not show archived items

  scope :active,    -> { where archived: false }

  # define scopes for filters

  scope :ff_seqno,  -> ( s ){ where seqno: s }
  scope :ff_desc,   -> ( d ){ where( 'description LIKE :param OR comment LIKE :param', param: "%#{ d }%" )}
  scope :ff_prio,   -> ( p ){ where prio: p }
  scope :ff_owner,  -> ( o ){ where account_id: o }
  scope :ff_status, -> ( s ){ where status: s }
  scope :ff_due,    -> ( d ){ where( 'due_date <= Date( ? )', d )}

  # returns the status label

  def status_label
    TIA_ITEM_STATUS_LABELS[ status ] unless status.nil?
  end

  def self.status_label( status )
    TIA_ITEM_STATUS_LABELS[ status ] unless status.nil?
  end

  # ... with it's index value

  def status_label_with_id
    some_text_and_id( TIA_ITEM_STATUS_LABELS[ status ], status ) unless status.nil?
  end

  def prio_label
    TIA_ITEM_PRIO_LABELS[ prio ] unless prio.nil?
  end

  def self.prio_label( prio )
    TIA_ITEM_PRIO_LABELS[ prio ] unless prio.nil?
  end

  # is the item's status still somewhat open?

  def status_open?
    status < 2
  end

  # allow to set archive only on closed items

  def archive_closed_only
    if archived and status_open? then
      errors.add( :archived, I18n.t( 'tia_items.msg.bad_archive' )) 
    end
  end

  private

    # ensure that archived is either true or false

    def set_defaults
      set_nil_default( :archived, false )
    end

end
