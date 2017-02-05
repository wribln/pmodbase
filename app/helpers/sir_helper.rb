module SirHelper

  # create action for SIR Entry:
  # :respond -> for_object: sir_item
  # :comment -> for_object: sir_item
  # :forward -> for_object: sir_item
  # :show    -> for_object: sir_entry
  # :edit    -> for_object: sir_entry
  # :delete  -> for_object: sir_entry

  def entry_action( action, for_object, parent = nil )
    case action
    when :forward
      '&#x25BA; '.html_safe << link_to( t( 'sir_items.show.forward' ), new_sir_entry_path( 0, for_object, parent ))
    when :comment
      '&#x25BC; '.html_safe << link_to( t( 'sir_items.show.comment' ), new_sir_entry_path( 1, for_object, parent ))
    when :respond
      '&#x25C4; '.html_safe << link_to( t( 'sir_items.show.respond' ), new_sir_entry_path( 2, for_object, parent ))
    when :show
      link_to( t( 'sir_items.show.show' ), sir_entry_path( for_object ))
    when :edit
      link_to( t( 'sir_items.show.edit' ), edit_sir_entry_path( for_object ))
    when :delete
      link_to( t( 'sir_items.show.delete' ), url_for( action: :destroy, id: for_object.id, controller: :sir_entries), method: :delete, data: { confirm: t('action_title.del_confirm' )})
    end
  end

  private

  # create url to create new SIR Entry with given type

  def new_sir_entry_path( rt, item, parent )
    url_options = { action: :new, controller: :sir_entries, sir_item_id: item, rec_type: rt }
    url_options[ :parent_id ] = parent unless parent.nil?
    url_for( url_options )
  end

end