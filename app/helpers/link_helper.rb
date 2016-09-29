module LinkHelper

  # provide a link to the contact list information of given account

  def link_to_contact_list( account, show_as = :link )
    link_to( account.user_name, contact_list_path( account.person ), set_html_options( show_as )) unless account.nil?
  end

  def link_to_account( account, show_as = :link )
    link_to( account.name_with_id, account_path( account ), set_html_options( show_as )) unless account.nil?
  end

  def link_to_cfr( cfr_record, show_as = :link )
    link_to( cfr_record.text_and_id( :title ), cfr_record_path( cfr_record ), set_html_options( show_as )) unless cfr_record.nil?
  end

  private

  def set_html_options( show_as )
    html_options = Hash.new 
    html_options[ :target ] = '_blank'
    html_options[ :class  ] = 'btn btn-default btn-block' if show_as == :button
    return html_options
  end

end
