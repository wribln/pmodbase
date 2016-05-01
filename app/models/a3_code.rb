require './lib/assets/app_helper.rb' 
class A3Code < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include ACodeModel

  # Discipline/System

  validates :code,
    format: { with: /\A.[A-Z0-9&]+\z/, message: I18n.t( 'a_code_modules.msg.bad_code_syntax1')},
    length: { maximum: 3 }

  validates :description,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  scope :as_desc, -> ( l ){ where( 'label LIKE :param OR description LIKE :param', param: "%#{ l }%" )}

end
