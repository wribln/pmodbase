class PcpCategory < ActiveRecord::Base
  include ApplicationModel
  include PcpSubjectAccess
  include GroupCheck

  belongs_to :c_group,  -> { readonly }, foreign_key: :c_group_id, class_name: Group
  belongs_to :p_group,  -> { readonly }, foreign_key: :p_group_id, class_name: Group
  belongs_to :c_owner,  -> { readonly }, foreign_key: :c_owner_id, class_name: Account
  belongs_to :p_owner,  -> { readonly }, foreign_key: :p_owner_id, class_name: Account
  belongs_to :c_deputy, -> { readonly }, foreign_key: :c_deputy_id, class_name: Account
  belongs_to :p_deputy, -> { readonly }, foreign_key: :p_deputy_id, class_name: Account
  has_many   :pcp_subjects, dependent: :destroy, validate: false, inverse_of: :pcp_category

  validates :label,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :c_group_id, :p_group_id, :c_owner_id, :p_owner_id,
    presence: true

  validates_each :c_group_id, :p_group_id do |r,a,v|
    r.given_group_exists( a )
  end
  
  validate{ given_account_has_access( :c_owner_id,  :c_group_id )}
  validate{ given_account_has_access( :c_deputy_id, :c_group_id )}
  validate{ given_account_has_access( :p_owner_id,  :p_group_id )}
  validate{ given_account_has_access( :p_deputy_id, :p_group_id )}

end
