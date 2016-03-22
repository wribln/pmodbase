require './lib/assets/app_helper.rb' 
class A1Code < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include ACodeModel

  # Project xxx

  validates :code,
    format: { with: /\A.[A-Z0-9]+\z/, message: I18n.t( 'a_code_modules.msg.bad_code_syntax ')},
    length: { maximum: 3 }

end
