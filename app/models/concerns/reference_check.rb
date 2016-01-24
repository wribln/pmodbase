# include this when you need the given_feature_exists functionality
# 
# include ReferenceCheck
#
# + add error message in I18n files for <table_name>.msg.bad_reference_id

module ReferenceCheck
  extend ActiveSupport::Concern

  # check if related record exists

  def given_reference_exists
    if self.reference_id.present?
      errors.add( :reference_id, I18n.t( "#{ self.class.table_name }.msg.bad_reference_id" )) \
        unless Reference.exists?( self.reference_id )
    end
  end

end