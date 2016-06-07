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

	default_scope { order( seqno: :asc, label: :asc )}

  # overwrite write accessor to ensure that [label] does not contain
  # any redundant blanks

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text ))
  end

end
