require './lib/assets/app_helper.rb'
class ProductCode < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include SCodeModel

  ProductCode.code_prefix = '-'

end