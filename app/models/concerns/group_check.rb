# include this when you need the given_feature_exists? functionality
# 
# include GroupCheck
#
# + add error message in I18n files for <table_name>.msg.bad_group_id

module GroupCheck
  extend ActiveSupport::Concern

  # check if related record exists

  def given_group_exists( group_id = :group_id )
    g_id = self.send( group_id )
    if g_id.present? then
      errors.add( group_id, I18n.t( "#{ self.class.table_name }.msg.bad_group_id" )) \
        unless Group.exists?( g_id )
    end
  end

  def given_group_exists_or_is_zero( group_id = :group_id )
    g_id = self.send( group_id )
    if g_id.present?
      errors.add( group_id, I18n.t( "#{ self.class.table_name }.msg.bad_group_id" )) \
        unless g_id == 0 || Group.exists?( g_id )
    end
  end

end