class OrlType < ActiveRecord::Base
  include ApplicationModel
  include GroupCheck

  belongs_to :o_group, -> { readonly }, foreign_key: :o_group_id, class_name: Group
  belongs_to :r_group, -> { readonly }, foreign_key: :r_group_id, class_name: Group

  validates :label,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :o_group_id, :r_group_id,
    presence: true

  validate{ given_group_exists( :o_group_id )}
  validate{ given_group_exists( :r_group_id )}

end
