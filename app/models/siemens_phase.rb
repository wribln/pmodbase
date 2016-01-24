require './lib/assets/app_helper.rb'
class SiemensPhase < ActiveRecord::Base
  include ApplicationModel
  include Filterable

  has_many :phase_codes, dependent: :destroy, inverse_of: :siemens_phase  

  validates :code,
    presence: true,
    uniqueness: true,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :label_p,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :label_m,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks 

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text, MAX_LENGTH_OF_CODE ))
  end

  def label_p=( text )
    write_attribute( :label_p, AppHelper.clean_up( text, MAX_LENGTH_OF_LABEL ))
  end

  def label_m=( text )
    write_attribute( :label_m, AppHelper.clean_up( text, MAX_LENGTH_OF_LABEL ))
  end

end
