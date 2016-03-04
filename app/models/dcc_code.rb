require './lib/assets/app_helper.rb'
class DccCode < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include CodeModel

  DccCode.code_prefix = '&'

end