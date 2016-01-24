# include this when you need the given_feature_exists functionality
# 
# include ReferenceCheck
#
# + add error message in I18n files for <table_name>.msg.bad_activity

module ProgrammeActivityCheck
  extend ActiveSupport::Concern

  # check if related record exists

  def given_programme_activity_exists( activity_id = :programme_activity_id )
    a_id = self.send( activity_id )
    if a_id.present? then
      errors.add( activity_id, I18n.t( "#{ self.class.table_name }.msg.bad_activity" )) \
        unless ProgrammeActivity.exists?( a_id )
    end
  end
end