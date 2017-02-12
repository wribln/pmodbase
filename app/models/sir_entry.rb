class SirEntry < ActiveRecord::Base
  include ApplicationModel

  belongs_to :sir_item, ->{ readonly }, inverse_of: :sir_entries
  belongs_to :group,    ->{ readonly }

  before_save :set_defaults

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

  # scope :log_order, ->{ reorder( created_at: :asc  )}
  # scope :rev_order, ->{ reorder( created_at: :desc )}

  scope :log_order, ->{ reorder( id: :asc  )}
  scope :rev_order, ->{ reorder( id: :desc )}

  # provide access to labels

  def rec_type_label
    SIR_ENTRY_REC_TYPE_LABELS[ rec_type ] unless rec_type.nil?
  end

  def group_code
    ( group.try :code ) || some_id( group_id )
  end

  # check if this is the last node in the log and could be deleted

  def is_last?
    sir_item.sir_entries.rev_order.first.id == id
  end

  private

    def validate_new_entry
      sir_item.validate_new_entry( self ) unless sir_item_id.nil?
    end
  
    def set_defaults
      set_nil_default( :is_public, false )
    end


end
