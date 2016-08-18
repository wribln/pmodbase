require "./lib/assets/app_helper.rb"
class TiaList < ActiveRecord::Base
  include ApplicationModel

  belongs_to :account,        -> { readonly }, inverse_of: :tia_lists
  belongs_to :owner_account,  -> { readonly }, foreign_key: 'owner_account_id',  class_name: 'Account'
  belongs_to :deputy_account, -> { readonly }, foreign_key: 'deputy_account_id', class_name: 'Account'
  has_many   :tia_items,                       inverse_of: :tia_list, dependent: :destroy
  has_many   :tia_members,                     inverse_of: :tia_list, dependent: :destroy
  accepts_nested_attributes_for :tia_members, allow_destroy: true
  validates_associated :tia_members

  validates :code,
    length: { maximum: MAX_LENGTH_OF_CODE },
    uniqueness: { scope: :owner_account_id }

  validates :label,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :owner_account_id,
    presence: true

  validate{ given_account_exists( :owner_account_id  )}
  validate{ given_account_exists( :deputy_account_id )}

  set_trimmed :code, :label

  # use this scope for own lists

  scope :for_user, -> ( id ){ where 'owner_account_id = :param OR deputy_account_id = :param', param: id }

  # check if related records exist

  def given_account_exists( name )
    if send( name ).present?
      errors.add( name, I18n.t( 'tia_lists.msg.account_nonexist' )) \
        unless Account.exists?( send( name ))
    end
  end

  # a helper to return a TIA item code

  def item_code( seqno )
    "#{ code }-#{ seqno }#{ '-' if code.nil? }" unless seqno.nil?
  end

  def next_seqno_for_item
    n = ( self.tia_items.maximum( :seqno ) || 0 ) + 1
  end

  # provide access checks

  def user_is_owner_or_deputy?( id )
    ( id == owner_account_id )||( id == deputy_account_id )
  end

  def permitted_to_access?( id )
    user_is_owner_or_deputy?( id )||tia_members.exists?( account: id, to_access: true )
  end

  def permitted_to_update?( id )
    user_is_owner_or_deputy?( id )||tia_members.exists?( account: id, to_access: true, to_update: true )
  end

  # create a list of possible owners for use in drop-down lists

  def accounts_for_select
    tia_members.pluck( :account_id ) + [ owner_account_id, deputy_account_id ].compact
  end

end
  