require './lib/assets/app_helper.rb'
class WebLink < ActiveRecord::Base
	include ApplicationModel

	validates :label,
		length: { maximum: MAX_LENGTH_OF_LABEL },
		presence: true

  validates :hyperlink,
    allow_blank: true,
    url: true

	validates :seqno,
		presence: true,
		numericality: { only_integer: true }

  set_trimmed :label

	default_scope { order( seqno: :asc, label: :asc )}

end
