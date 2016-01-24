# include this when you need the given_feature_exists? functionality
# 
# include PersonCheck
#
# + add error message in I18n files for <table_name>.msg.bad_person_id

module PersonCheck
  extend ActiveSupport::Concern

  # check if related record exists

  def given_person_exists
    if self.person_id.present?
      errors.add( :person_id, I18n.t( "#{ self.class.table_name }.msg.bad_person_id" )) \
        unless Person.exists?( self.person_id )
    end
  end

  def given_person_exists_or_is_zero
    if self.person_id.present?
      errors.add( :person_id, I18n.t( "#{ self.class.table_name }.msg.bad_person_id" )) \
        unless self.person_id == 0 || Person.exists?( self.person_id )
    end
  end

end