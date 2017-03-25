module SirHelper

  # create action for SIR Entry:
  # :respond -> for_object: sir_item
  # :comment -> for_object: sir_item
  # :forward -> for_object: sir_item
  # :show    -> for_object: sir_entry
  # :edit    -> for_object: sir_entry
  # :delete  -> for_object: sir_entry

  def entry_action( action, for_object )
    case action
    when :forward
      '&#x25BA; '.html_safe << link_to( t( 'sir_items.show.forward' ), new_sir_entry_path( 0, for_object ))
    when :comment
      '&#x25BC; '.html_safe << link_to( t( 'sir_items.show.comment' ), new_sir_entry_path( 1, for_object ))
    when :respond
      '&#x25C4; '.html_safe << link_to( t( 'sir_items.show.respond' ), new_sir_entry_path( 2, for_object ))
    when :show
      link_to( t( 'sir_items.show.show' ), sir_entry_path( for_object ))
    when :edit
      link_to( t( 'sir_items.show.edit' ), edit_sir_entry_path( for_object ))
    when :delete
      link_to( t( 'sir_items.show.delete' ), url_for( action: :destroy, id: for_object.id, controller: :sir_entries), method: :delete, data: { confirm: t('action_title.del_confirm' )})
    end
  end

  def sir_entry_heading( entry )
    h = "[#{ db_formatted_d( entry.updated_at )}] #{ entry.rec_type_label } "
    case entry.rec_type
    when 0
      h += entry.orig_group_code + ' &#x25BA; ' + entry.resp_group_code
    when 1
      h += entry.orig_group_code
      h += ' &#x25C4; ' + entry.resp_group_code unless entry.orig_group_id == entry.resp_group_id
    when 2
      h += entry.orig_group_code + '&#x25BA; ' + entry.resp_group_code
    end
    h += t( 'sir_items.show.due_by', due_date: entry.due_date ) unless entry.due_date.nil?
    h.html_safe
  end

  private

  # create url to create new SIR Entry with given type

  def new_sir_entry_path( rt, item )
    url_options = { action: :new, controller: :sir_entries, sir_item_id: item, rec_type: rt }
    url_for( url_options )
  end

end