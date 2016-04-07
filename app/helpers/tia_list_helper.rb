module TiaListHelper

  # provide a link to the contact list information of given account

  def link_to_contact_list( account, show_as = :link )
    link_to( account.user_name, contact_list_path( account.person ), set_html_options( show_as )) unless account.nil?
  end

  def link_to_account( account, show_as = :link )
    link_to( account.name_with_id, account_path( account ), set_html_options( show_as )) unless account.nil?
  end

  private

  def set_html_options( show_as )
    html_options = Hash.new 
    html_options[ :target ] = '_blank'
    html_options[ :class  ] = 'btn btn-default btn-block' if show_as == :button
    return html_options
  end

end
