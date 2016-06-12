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

  # see Group.permitted_groups: Create scope which selects all PCP Categories containing
  # the given group ids:

  def self.permitted_groups( pg )
    case pg
    when nil
      none
    when ''
      all
    else
      where( 'p_group_id IN ( :param ) OR c_group_id IN ( :param )', param: pg )
    end
  end

  # check if the current account is permitted to create a PCP Subject for this
  # PCP Category: It must be the owner or deputy of that PCP Category. 

  def permitted_to_create_subject?( account )
    account.id == p_owner_id || account.id == p_deputy_id
  end

  # provide labels with id suffix

  def label_with_id
    text_and_id( :label )
  end  

end
