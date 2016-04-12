class OrlCategory < ActiveRecord::Base
  include ApplicationModel
  include AccountCheck
  include GroupCheck

  belongs_to :o_group,  -> { readonly }, foreign_key: :o_group_id, class_name: Group
  belongs_to :r_group,  -> { readonly }, foreign_key: :r_group_id, class_name: Group
  belongs_to :o_owner,  -> { readonly }, foreign_key: :o_owner_id, class_name: Account
  belongs_to :r_owner,  -> { readonly }, foreign_key: :r_owner_id, class_name: Account
  belongs_to :o_deputy, -> { readonly }, foreign_key: :o_deputy_id, class_name: Account
  belongs_to :r_deputy, -> { readonly }, foreign_key: :r_deputy_id, class_name: Account

  validates :label,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :o_group_id, :r_group_id, :o_owner_id, :r_owner_id,
    presence: true

  validate{ given_group_exists( :o_group_id )}
  validate{ given_group_exists( :r_group_id )}

  validate{ given_account_exists( :o_owner_id  )}
  validate{ given_account_exists( :r_owner_id  )}
  validate{ given_account_exists( :o_deputy_id )}
  validate{ given_account_exists( :r_deputy_id )}

end
