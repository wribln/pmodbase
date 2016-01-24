# include this when you need the given_feature_exists functionality
# 
# include FeatureCheck
#
# + add error message in I18n files for <table_name>.msg.bad_feature_id

module FeatureCheck
  extend ActiveSupport::Concern

  # check if related record exists

  def given_feature_exists
    if self.feature_id.present?
      errors.add( :feature_id, I18n.t( "#{ self.class.table_name }.msg.bad_feature_id" )) \
        unless Feature.exists?( self.feature_id )
    end
  end

end