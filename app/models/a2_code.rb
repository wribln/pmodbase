require './lib/assets/app_helper.rb' 
class A2Code < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include ACodeModel

  # Stage

  validates :code,
    format: { with: /\A.[0-9]+\z/, message: I18n.t( 'a_code_modules.msg.bad_code_syntax ')},
    length: { maximum: 3 }

end
