class SirEntry < ActiveRecord::Base
  include ApplicationModel

  belongs_to :sir_item, inverse_of: :sir_entries
  belongs_to :group,    ->{ readonly }

  before_destroy :check_before_destroy
  before_update :check_before_update
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

  # the following attribute is used when creating views of all entries

  attr_accessor :visibility

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

  def check_before_destroy
    unless rec_type == 1 || sir_item.sir_entries.last.id == id
      errors.add( :base, I18n.t( 'sir_items.msg.bad_del_req' ))
      throw :abort
    end
  end

  def check_before_update
    unless sir_item.sir_entries.last.id == id
      errors.add( :base, I18n.t( 'sir_items.msg.bad_upd_req' ))
      throw :abort
    end
  end

  # entry is defined as visible if it has a visibility flag of > 0

  def is_visible?
    visibility && ( visibility > 0 )
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
