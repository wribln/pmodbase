# include this when you need the given_group_category_exists? functionality
# 
# include GroupCategoryCheck
#
# + add error message in I18n files for <table_name>.msg.bad_group_cat

module GroupCategoryCheck
  extend ActiveSupport::Concern

  # check if related record exists

  def given_group_category_exists
    if self.group_category_id.present?
      errors.add( :group_category_id, I18n.t( "#{ self.class.table_name }.msg.bad_group_cat" )) \
        unless GroupCategory.exists?( self.group_category_id )
    end
  end

end