# include this when you need the given_feature_exists? functionality
# 
# include FeatureCategoryCheck
#
# + add error message in I18n files for <table_name>.msg.bad_feature_cat

module FeatureCategoryCheck
  extend ActiveSupport::Concern

  # check if related record exists

  def given_feature_category_exists
    if self.feature_category_id.present?
      errors.add( :feature_category_id, I18n.t( "#{ self.class.table_name }.msg.bad_feature_cat" )) \
        unless FeatureCategory.exists?( self.feature_category_id )
    end
  end

end