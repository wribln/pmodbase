require './lib/assets/app_helper.rb'
class IsrInterface < ActiveRecord::Base
  include ApplicationModel
  include AccountAccess  
  include Filterable

  belongs_to :l_group,    -> { readonly }, foreign_key: :l_group_id, class_name: :Group
  belongs_to :p_group,    -> { readonly }, foreign_key: :p_group_id, class_name: :Group
  belongs_to :l_owner,    -> { readonly }, foreign_key: :l_owner_id, class_name: :Account
  belongs_to :l_deputy,   -> { readonly }, foreign_key: :l_deputy_id, class_name: :Account
  belongs_to :p_owner,    -> { readonly }, foreign_key: :p_owner_id, class_name: :Account
  belongs_to :p_deputy,   -> { readonly }, foreign_key: :p_deputy_id, class_name: :Account
  belongs_to :cfr_record, -> { readonly }

  validates :l_group,
    presence: true, if: Proc.new{ |me| me.l_group_id.present? }

  validates :p_group,
    presence: true, if: Proc.new{ |me| me.p_group_id.present? }

  validates :l_owner,
    presence: true, if: Proc.new{ |me| me.l_owner_id.present? }

  validates :p_owner,
    presence: true, if: Proc.new{ |me| me.p_owner_id.present? }

  validates :l_deputy,
    presence: true, if: Proc.new{ |me| me.l_deputy_id.present? }

  validates :p_deputy,
    presence: true, if: Proc.new{ |me| me.p_deputy_id.present? }

  validates :cfr_record,
    presence: true, if: Proc.new{ |me| me.cfr_record_id.present? }

  validates :title,
    length: { maximum: MAX_LENGTH_OF_TITLE }

  validates :desc,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  ISR_IF_LEVEL_LABELS = IsrInterface.human_attribute_name( :if_levels ).freeze

  validates :if_level, 
    presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..( ISR_IF_LEVEL_LABELS.size - 1 )}

  ISR_IF_STATUS_LABELS = IsrInterface.human_attribute_name( :if_states ).freeze

  validates :if_status,
    presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..( ISR_IF_STATUS_LABELS.size - 1 )}

  validate{ given_account_has_access( :l_owner_id,  :l_group_id, FEATURE_ID_ISR_INTERFACES )}
  validate{ given_account_has_access( :l_deputy_id, :l_group_id, FEATURE_ID_ISR_INTERFACES )}
  validate{ given_account_has_access( :p_owner_id,  :p_group_id, FEATURE_ID_ISR_INTERFACES )}
  validate{ given_account_has_access( :p_deputy_id, :p_group_id, FEATURE_ID_ISR_INTERFACES )}

  set_trimmed :title

end
