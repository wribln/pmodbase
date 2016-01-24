# include this when you need the given_feature_exists functionality
# 
# include RegionNameCheck
#
# + add error message in I18n files for <table_name>.msg.bad_region_id

module RegionNameCheck
  extend ActiveSupport::Concern

  # check if related record exists

  def given_region_name_exists
    if self.region_name_id.present?
      errors.add( :region_name_id, I18n.t( "#{ self.class.table_name }.msg.bad_region_id" )) \
        unless RegionName.exists?( self.region_name_id )
    end
  end

end