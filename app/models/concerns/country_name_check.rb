# include this when you need the given_feature_exists functionality
# 
# include CountryNameCheck
#
# + add error message in I18n files for <table_name>.msg.bad_country_id

module CountryNameCheck
  extend ActiveSupport::Concern

  # check if related record exists

  def given_country_name_exists
    if self.country_name_id.present?
      errors.add( :country_name_id, I18n.t( "#{ self.class.table_name }.msg.bad_country_id" )) \
        unless CountryName.exists?( self.country_name_id )
    end
  end

end