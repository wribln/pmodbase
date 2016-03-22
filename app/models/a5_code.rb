require './lib/assets/app_helper.rb' 
class A5Code < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include ACodeModel

  # Activity

  validates :code,
    format: { with: /\A.[A-Z0-9&]+\z/, message: I18n.t( 'a_code_modules.msg.bad_code_syntax ')},
    length: { maximum: 3 }

  validates :desc,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  scope :as_desc, -> ( l ){ where( 'label LIKE ? OR desc LIKE ?', "%#{ l }%", "%#{ l }%" )}

end
