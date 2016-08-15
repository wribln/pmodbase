class PcpMember < ActiveRecord::Base

  belongs_to :pcp_subject,  -> { readonly }, inverse_of: :pcp_members
  belongs_to :account,      -> { readonly }, inverse_of: :pcp_members

  validates :pcp_subject,
    presence: true

  validates :account_id,
    uniqueness: { scope: [ :pcp_subject_id, :pcp_group ],
      message: I18n.t( 'pcp_members.msg.dup_account_id' )}

  validates :account,      
    presence: true

  PCP_GROUP_LABELS = PcpMember.human_attribute_name( :pcp_groups ).freeze

  validates :pcp_group,
    presence: true,
    inclusion: { in: (0..1) }

#  validate :given_subject_exists
  validate :update_requires_access

  scope :presenting_group, -> { where( pcp_group: 0 )}
  scope :commenting_group, -> { where( pcp_group: 1 )}
  scope :presenting_member, ->( m ){ presenting_group.where( account_id: m )}
  scope :commenting_member, ->( m ){ commenting_group.where( account_id: m )}

  # if to_update is set, to_access must also be set: this could be done
  # by default but I cannot assume that this was the user's intention

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
