# include this when you need the given_account_exists functionality
# 
# include AccountCheck
#
# + add error message in I18n files for <table_name>.msg.bad_account_id

module AccountCheck
  extend ActiveSupport::Concern

  # check if related record exists

  def given_account_exists
    if self.account_id.present?
      errors.add( :account_id, I18n.t( "#{ self.class.table_name }.msg.bad_account_id" )) \
        unless Account.exists?( self.account_id )
    end
  end

end