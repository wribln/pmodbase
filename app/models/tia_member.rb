class TiaMember < ActiveRecord::Base
  include ApplicationModel
  include AccountCheck
  include TiaListCheck
 
  belongs_to :account,  -> { readonly }, inverse_of: :tia_members
  belongs_to :tia_list, -> { readonly }, inverse_of: :tia_members

  validates :account_id,
    uniqueness: { scope: :tia_list_id, message: I18n.t( 'tia_members.msg.dup_account_id' )},
    presence: true

  validates :tia_list_id,
    presence: true

  validate :account_not_owner_or_deputy
  validate :given_tia_list_exists
  validate :given_account_exists

  # a member must not be owner or deputy at the same time as they are
  # already default members with access and update rights

  def account_not_owner_or_deputy
    errors.add( :account_id, I18n.t( 'tia_members.msg.own_account_id' )) \
      if tia_list_id && account_id && tia_list.user_is_owner_or_deputy?( account_id )
  end

end
