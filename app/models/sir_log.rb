class SirLog < ActiveRecord::Base
  include ApplicationModel

  has_many :sir_items, -> { readonly }, inverse_of: :sir_log

  validates :label,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :desc,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  set_trimmed :label, :desc

end
