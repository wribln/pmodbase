# include this when you need the given_account_exists functionality
# 
# include AccountCheck
#
# + add error message in I18n files for <table_name>.msg.bad_account_id

module TiaListCheck
  extend ActiveSupport::Concern

  # check if related record exists

  def given_tia_list_exists
    if self.tia_list_id.present?
      errors.add( :tia_list_id, I18n.t( 'tia_lists.msg.bad_tia_list_id' )) \
        unless TiaList.exists?( self.tia_list_id )
    end
  end

end