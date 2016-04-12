# include this when you need the given_account_exists functionality
# 
# include AccountCheck
#
# + add error message in I18n files for <table_name>.msg.bad_account_id

module AccountCheck
  extend ActiveSupport::Concern

  # check if related record exists

  def given_account_exists( account_id = :account_id )
    a_id = self.send( account_id )
    if a_id.present?
      errors.add( account_id, I18n.t( "#{ self.class.table_name }.msg.bad_account_id" )) \
        unless Account.exists?( a_id )
    end
  end

end