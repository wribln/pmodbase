class PcpMember < ActiveRecord::Base
  include AccountCheck

  belongs_to :pcp_subject,  -> { readonly }, inverse_of: :pcp_members
  belongs_to :account,      -> { readonly }, inverse_of: :pcp_members

  validates :pcp_subject_id,
    presence: true

  validates :account_id,
    uniqueness: { scope: [ :pcp_subject_id, :pcp_group ],
      message: I18n.t( 'pcp_members.msg.dup_account_id' )},
    presence: true

  PCP_GROUP_LABELS = PcpMember.human_attribute_name( :pcp_groups ).freeze

  validates :pcp_group,
    presence: true,
    inclusion: { in: (0..1) }

  validate :given_account_exists
  validate :given_subject_exists
  validate :update_requires_access

  scope :presenting_group, -> { where( pcp_group: 0 )}
  scope :commenting_group, -> { where( pcp_group: 1 )}

  # a member must not be owner or deputy of the givene PCP Subject
  # at the same time as they are already default members with
  # access and update rights for their respective PCP Group

  def account_not_owner_or_deputy
    errors.add( :account_id, I18n.t( 'pcp_members.msg.own_account_id' )) \
      if pcp_subject_id && account_id && pcp_subject.user_is_owner_or_deputy?( account_id )
  end

  # pcp subject must exist

  def given_subject_exists
    errors.add( :pcp_subject_id, I18n.t( 'pcp_members.msg.bad_subject_id' )) \
      unless PcpSubject.exists?( pcp_subject_id )
  end

  # if to_update is set, to_access must also be set

  def update_requires_access
    errors.add( :to_access, I18n.t( 'pcp_members.msg.access_req' )) \
      if to_update && !to_access
  end

  def pcp_group_label
    PCP_GROUP_LABELS[ pcp_group ]
  end    

  def self.pcp_group_label( agp )
    PCP_GROUP_LABELS[ agp ]
  end

end
