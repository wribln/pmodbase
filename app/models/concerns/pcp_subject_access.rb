# include this when you need the given_feature_exists? functionality
# 
# include PcpSubjectAccess
#
# + add error message in I18n files for <table_name>.msg.bad_address_id

module PcpSubjectAccess
  extend ActiveSupport::Concern

  # Make sure that the given account has modify access for PCP Subjects
  # in the given group (when used inside PcpCategory) or for this PCP
  # Subject (when used inside PcpSubject).
  # Perform checks only if there are no earlier errors on the given
  # attributes; note: permission_to_access checks for active accounts.

  def given_account_has_access( account_id, group_id )
    return if errors.include?( account_id )
    a_id = self.send( account_id )
    return if a_id.nil?
    a = Account.where( id: a_id )
    if a.empty? then
      errors.add( account_id, I18n.t( "#{ self.class.table_name }.msg.bad_account_id" ))
      return # no need to look for errors any further...
    else
      a = a.first
    end
    return if errors.include?( group_id )
    g_id = self.send( group_id )
    return if g_id.nil?
    errors.add( account_id, I18n.t( "#{ self.class.table_name }.msg.no_access" )) \
      unless a.permission_to_access( FEATURE_ID_MY_PCP_SUBJECTS, :to_update, g_id )
  end

end