require "./lib/assets/app_helper.rb"
class FeatureCategory < ActiveRecord::Base
  include ApplicationModel  

  has_many :features, dependent: :destroy, inverse_of: :feature_category

  validates :label,
    length: { maximum: MAX_LENGTH_OF_LABEL },
    presence: true

  validates :seqno,
    presence: true,
    numericality: { only_integer: true }

  default_scope { order( seqno: :asc, label: :asc )}

  set_trimmed :label

end
