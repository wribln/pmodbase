class OrlCategory < ActiveRecord::Base
  include ApplicationModel
  include OrlSubjectAccess
  include GroupCheck

  belongs_to :o_group,  -> { readonly }, foreign_key: :o_group_id, class_name: Group
  belongs_to :r_group,  -> { readonly }, foreign_key: :r_group_id, class_name: Group
  belongs_to :o_owner,  -> { readonly }, foreign_key: :o_owner_id, class_name: Account
  belongs_to :r_owner,  -> { readonly }, foreign_key: :r_owner_id, class_name: Account
  belongs_to :o_deputy, -> { readonly }, foreign_key: :o_deputy_id, class_name: Account
  belongs_to :r_deputy, -> { readonly }, foreign_key: :r_deputy_id, class_name: Account
  has_many   :orl_subjects, dependent: :destroy, validate: false, inverse_of: :orl_category

  validates :label,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :o_group_id, :r_group_id, :o_owner_id, :r_owner_id,
    presence: true

  validates_each :o_group_id, :r_group_id do |r,a,v|
    r.given_group_exists( a )
  end
  
  validate{ given_account_has_access( :o_owner_id,  :o_group_id )}
  validate{ given_account_has_access( :o_deputy_id, :o_group_id )}
  validate{ given_account_has_access( :r_owner_id,  :r_group_id )}
  validate{ given_account_has_access( :r_deputy_id, :r_group_id )}

end
