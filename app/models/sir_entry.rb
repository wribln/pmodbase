class SirEntry < ActiveRecord::Base
  include ApplicationModel

  belongs_to :sir_item, inverse_of: :sir_entries
  belongs_to :group,    ->{ readonly }

  after_save    :update_item
  after_destroy :release_item

  validates :sir_item,
    presence: true

  validates :group,
    presence: true

  SIR_ENTRY_REC_TYPE_LABELS = SirEntry.human_attribute_name( :rec_types ).freeze

  validates :rec_type,
    presence: true,
    inclusion: { in: 0..2 }

  validates :due_date,
    date_field: { presence: false }

  validate :validate_new_entry, on: :create

  # scopes

  scope :log_order, ->{ reorder( created_at: :asc  )}
  scope :rev_order, ->{ reorder( created_at: :desc )}

  # provide access to labels

  def rec_type_label
    SIR_ENTRY_REC_TYPE_LABELS[ rec_type ] unless rec_type.nil?
  end

  def group_code
    ( group.try :code ) || some_id( group_id )
  end

  # can only destroy entry if it is a comment or the last entry in a thread

  def destroyable?
    rec_type == 1 || sir_item.sir_entries.last.id == id
  end

  private

    def validate_new_entry
      sir_item.validate_new_entry( self ) unless sir_item_id.nil?
    end

    def update_item
      sir_item.status = 1
    end

    def release_item
      sir_item.status = nil
    end
 
end
