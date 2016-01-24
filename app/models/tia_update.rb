class TiaUpdate < ActiveRecord::Base
  include ApplicationModel
  include AccountCheck
  
  belongs_to  :tia_item,  -> { readonly }, inverse_of: :tia_updates
  belongs_to  :account,   -> { readonly }, inverse_of: :tia_updates

  validates :tia_item_id,
    presence: true

  validate :given_tia_item_exists

  validates :description,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  validates :comment,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  TIA_ITEM_PRIO_LABELS = TiaItem.human_attribute_name( :priorities ).freeze

  validates :prio,
    allow_nil: true,
    inclusion: { in: 0..( TIA_ITEM_PRIO_LABELS.size - 1 )}

  TIA_ITEM_STATUS_LABELS = TiaItem.human_attribute_name( :states ).freeze

  validates :status,
    allow_nil: true,
    inclusion: { in: 0..( TIA_ITEM_STATUS_LABELS.size - 1 )}

  validate :given_account_exists # need this to access names for display

  validates :due_date,
    date_field: { presence: false }

  default_scope { order( created_at: :desc )}

  # copy all fields which are different in the two TiaItem's
  # if nothing was copied, leave reference to TiaItem (to_tia_item)
  # nil, else set to it to the id of the first item

  FIELDS_TO_COPY = %w(
    description
    comment
    account_id
    prio
    status
    due_date
    archived )

  def copy_changes( from_tia_item, to_tia_item )
    n = 0
    FIELDS_TO_COPY.each do |f|
      if from_tia_item[ f ] == to_tia_item[ f ] then
        self[ f ] = nil
      else
        self[ f ] = from_tia_item[ f ]
        n += 1
      end
    end

    # set reference to TiaItem only if record is not empty
    # to force valid? to fail

    self.tia_item_id = ( n > 0 )? to_tia_item.id : nil
  end

  def fields_updated
    n = 0
    FIELDS_TO_COPY.each do |f|
      n += 1 unless self[ f ].nil?
    end
    n
  end

  def status_label
    TIA_ITEM_STATUS_LABELS[ status ] unless status.nil?
  end

  def prio_label
    TIA_ITEM_PRIO_LABELS[ prio ] unless prio.nil?
  end

  private

  # make sure this links backward correctly

    def given_tia_item_exists
      if self.tia_item_id.present?
        errors.add( :tia_item_id, I18n.t( "our_tia_items.msg.bad_tia_item_id" )) \
          unless TiaItem.exists?( self.tia_item_id )
      end
    end

end
