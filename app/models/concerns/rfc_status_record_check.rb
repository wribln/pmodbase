# include this when you need the given_feature_exists functionality
# 
# include RfcStatusRecordCheck
#
# + add error message in I18n files for <table_name>.msg.bad_region_id

module RfcStatusRecordCheck
  extend ActiveSupport::Concern

  # check if related record exists

  def given_rfc_status_record_exists
    if self.rfc_status_record_id.present?
      errors.add( :rfc_status_record_id, I18n.t( "#{ self.class.table_name }.msg.bad_region_id" )) \
        unless RfcStatusRecord.exists?( self.rfc_status_record_id )
    end
  end

end