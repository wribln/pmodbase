# this module supports specifically filter features
#
module FilterHelper

  # A normal check_box cannot be used for filtering as we need not only the
  # true/set and false/clear states but also the additional state 'unused'.
  #
  # The methods below implement the checkbox using a selector with a blank
  # line (unused/nothing selected - default), and two lines for true/set and
  # false/clear. 
  #
  # The implemented scheme is consistent with search_fields as the field
  # name is returned with an empty value if nothing was specified, else the
  # specified value (0 for false, 1 for true) is returned.
  #
  # Pass the filter_fields hash variabile, the related key, and the scope
  # for the translation of the values true_val and false_val: the combined
  # scope assumes t_scope.key.true_val and t_scope.key.false_val
  #
  # The related scope in the model must consider '0' for false, and '1' for
  # true, e.g. by saying:
  #   scope :x_filter, -> ( x_val ){ where x_var: ( x_val == '1' )}

  def filter_check_box( hash_var, key, t_scope = controller_name )
    select_tag( key,
      options_for_select([
        [' ', nil ],
        [ t( 'true_val', scope: [ t_scope, key ]), 1 ],
        [ t( 'false_val', scope:[ t_scope, key ]), 0 ]],
        hash_var[ key ]),
      class: 'form-control input-sm' )
  end

  # Selection field with multiple selection option: assure that default values
  # are set correctly as integers.
  #
  # [hash_var]    this is normally the hash with the permitted filter fields;
  #               computation: params.slice( :<ff_code>, ... ).clean_up
  # [key]         the filter field key to be used for this select_tag
  # [collection]  the collection of values to present, for example, to use
  #               all records of type Reference, you would use Reference.all,
  #               or compute this set as an instance variable of the controller
  # [lab]         specifies what to show as label in the selection: this must
  #               be a method of the collection objects
  # [val]         by default this is :id which will cause the :id of the
  #               collection to be used as value; it can be set to nil to 
  #               force the label (as defined by the parameter lab) to be
  #               used as value parameter

  def filter_multi_select( hash_var, key, collection, lab, val=:id )
    select_tag( key,
      options_from_collection_for_select( collection, val.nil? ? lab : val, lab, set_value( hash_var, key )),
      include_blank: true, multiple: true, class: 'form-control input-sm col-sm-12' )
  end

  # Selection field with single selection: parameters are the same as for the
  # filter_multi_select method

  def filter_single_select( hash_var, key, collection, lab, val=:id )
    select_tag( key, 
      options_from_collection_for_select( collection, val.nil? ? lab : val, lab, set_value( hash_var, key )),
      include_blank: true, multiple: false, class: 'form-control input-sm col-sm-12' )
  end

  def filter_select_from_array( array_var, key, collection )
    select_tag( key,
      options_for_select( collection, set_value( array_var, key )),
      include_blank: true, multiple: false, class: 'form-control input-sm col-sm-12' )
  end

  # use this if you have an array of strings and you want the index returned

  def filter_select_from_string_set( array_var, key, collection )
    select_tag( key, 
      options_for_select( collection.each_with_index.map{ |s, i| [ s, i ]}, set_value( array_var, key )),
      include_blank: true, multiple: false, class: 'form-control input-sm col-sm-12' )
  end

  # internal helper function for the above to ease determination of default value:
  # return nil if key is nil, else return the value of the respective collection entry

  def set_value( collection, index )
    case collection[ index ]
      when NilClass then nil
      when Enumerable then collection[ index ].map( &:to_i )
      when String then collection[ index ]
      else collection[ index ].to_i
    end
  end
  private :set_value

  # insert a tr filter row tag with 'style="display:none"' if parameter
  # is empty (expected hash), also insert appropriate class for javascript

  def filter_row( hash_var )
    html = 'class="filter-row"'
    html += ' style="display:none"' if hash_var.empty?
    html.html_safe
  end

  # insert a search field from the filter hash

  def filter_field( hash_var, key, prompt )
    search_field_tag key, hash_var[ key ], class: 'form-control input-sm', placeholder: t( prompt, scope: 'action_title.filter_ph.' )
  end

  # insert filter action header

  def filter_action_title_header( header = 'action_title.header')
    html = t( header )
    html += '&nbsp;'
    html += link_to 'Y', '#', class: 'btn btn-default btn-xs show-filter-row hidden-print', title: t('action_title.filter')
    html.html_safe
  end

  # insert the filter action button

  def filter_action_button
    content_tag( :div,
      submit_tag( t( 'button_label.filter'), name: nil, class: 'btn btn-default btn-sm', title: t( 'action_title.filter_and')),
      class: "btn-group")
  end

end