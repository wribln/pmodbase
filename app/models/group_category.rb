require "./lib/assets/app_helper.rb"
class GroupCategory < ActiveRecord::Base
  include ApplicationModel

  has_many :groups, dependent: :destroy, inverse_of: :group_category

  validates :label,
    length: { maximum: MAX_LENGTH_OF_LABEL },
    presence: true

  validates :seqno,
    presence: true,
    numericality: { only_integer: true }

  set_trimmed :label

end
