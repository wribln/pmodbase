require './lib/assets/app_helper.rb'
class ServiceCode < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include SCodeModel

  ServiceCode.code_prefix = '$'

end