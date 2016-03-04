require './lib/assets/app_helper.rb'
class ServiceCode < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include CodeModel

  ServiceCode.code_prefix = '$'

end