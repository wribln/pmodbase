# include this when you need the given_location_code_exists? functionality
# 
# include LocationCodeCheck
#
# + add error message in I18n files for <table_name>.msg.bad_loc_code

module LocationCodeCheck
  extend ActiveSupport::Concern

  # check if related record exists

  def given_location_code_exists
    if self.location_code_id.present?
      errors.add( :location_code_id, I18n.t( "#{ self.class.table_name }.msg.bad_loc_code" )) \
        unless LocationCode.exists?( self.location_code_id )
    end
  end

end