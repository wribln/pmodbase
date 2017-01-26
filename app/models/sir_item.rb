class SirItem < ActiveRecord::Base
  include ApplicationModel

  belongs_to :sir_log
  belongs_to :group
  belongs_to :cfr_record
  belongs_to :phase_code

end
