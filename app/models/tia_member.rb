# NOTE: this model is almost identical to sir_member

class TiaMember < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd
 
  belongs_to :account,  -> { readonly }, inverse_of: :tia_members
  belongs_to :tia_list, -> { readonly }, inverse_of: :tia_members

  validates :account,
    presence: true

  validates :account_id,
    uniqueness: { scope: :tia_list_id, message: I18n.t( 'tia_members.msg.dup_account_id' )}

  validates :tia_list,
    presence: true

  validate :account_not_owner_or_deputy

  # a member must not be owner or deputy at the same time as they are
  # already default members with access and update rights

  def account_not_owner_or_deputy
    errors.add( :account_id, I18n.t( 'tia_members.msg.own_account_id' )) \
      if tia_list_id && account_id && tia_list.user_is_owner_or_deputy?( account_id )
  end

end
