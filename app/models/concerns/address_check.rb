# include this when you need the given_feature_exists? functionality
# 
# include AddressCheck
#
# + add error message in I18n files for <table_name>.msg.bad_address_id

module AddressCheck
  extend ActiveSupport::Concern

  # check if related record exists

  def given_address_exists
    if self.address_id.present?
      errors.add( :address_id, I18n.t( "#{ self.class.table_name }.msg.bad_address_id" )) \
        unless Address.exists?( self.address_id )
    end
  end

end