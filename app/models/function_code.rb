require './lib/assets/app_helper.rb' 
class FunctionCode < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include SCodeModel

  FunctionCode.code_prefix = '='

end