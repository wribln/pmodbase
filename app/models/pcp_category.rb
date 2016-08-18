class PcpCategory < ActiveRecord::Base
  include ApplicationModel
  include PcpSubjectAccess

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

  validates :c_group,
    presence: true

  validates :p_group,
    presence: true

  validates :c_owner,
    presence: true

  validates :p_owner,
    presence: true

  validates :c_deputy,
    presence: true, if: Proc.new{ |me| me.c_deputy_id.present? }

  validates :p_deputy,
    presence: true, if: Proc.new{ |me| me.p_deputy_id.present? }

  validate{ given_account_has_access( :c_owner_id,  :c_group_id )}
  validate{ given_account_has_access( :p_owner_id,  :p_group_id )}

  # return a scope to select all PCP Categories for which the current user has
  # permission to create subjects for: i.e. she either belongs to the presenting
  # group or is deputy for the presenting group.

  def self.permitted_to_create_subject( pg, account )
    case pg
    when nil
      where( p_deputy_id: account.id )
    when ''
      all
    else
      where( 'p_group_id IN ( ? ) OR p_deputy_id = ?', pg, account.id )
    end
  end

  # provide labels with id suffix

  def label_with_id
    text_and_id( :label )
  end  

end
