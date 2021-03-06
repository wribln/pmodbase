require './lib/assets/app_helper.rb'
class SiemensPhase < ActiveRecord::Base
  include ApplicationModel
  include Filterable

  has_many :phase_codes, dependent: :destroy, inverse_of: :siemens_phase  

  validates :code,
    presence: true,
    uniqueness: true,
    format: { with: /\A.[A-Z0-9.\-]+\z/, message: I18n.t( 's_code_modules.msg.bad_code_syntax' )},
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :label_p,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :label_m,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  set_trimmed :code, :label_p, :label_m

  def code_and_label
    '' << try( :code ) << ' - ' << try( :label_p )
  end

end
