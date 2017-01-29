# NOTE: this model is almost identical to tia_member

class SirMember < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd
 
  belongs_to :account,  -> { readonly }, inverse_of: :sir_members
  belongs_to :sir_log,  -> { readonly }, inverse_of: :sir_members

  validates :account,
    presence: true

  validates :account_id,
    uniqueness: { scope: :sir_log_id, message: I18n.t( 'sir_members.msg.dup_account_id' )}

  validates :sir_log,
    presence: true

  validate :account_not_owner_or_deputy

  # a member must not be owner or deputy at the same time as they are
  # already default members with access and update rights

  def account_not_owner_or_deputy
    errors.add( :account_id, I18n.t( 'sir_members.msg.own_account_id' )) \
      if sir_log_id && account_id && sir_log.user_is_owner_or_deputy?( account_id )
  end

end
