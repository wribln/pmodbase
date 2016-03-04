require './lib/assets/app_helper.rb'
class ProductCode < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include CodeModel

  ProductCode.code_prefix = '-'

end