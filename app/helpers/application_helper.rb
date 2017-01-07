module ApplicationHelper

  # format an integer as mileage xxx+xxx

  def db_formatted_km( i )
    i.to_s
  end

  # This method is the standard format for dates and times

  def db_formatted_d( d )
    d.try( :to_formatted_s, :db_date )
  end

  def db_formatted_dt( t )
    t.try( :to_formatted_s, :db_time )
  end

  def db_formatted_number( d )
    number_with_delimiter( d, separator: '.', delimiter: ' ' )
  end

  # insert a page title from the I18n library
  
  def page_title( this_title = nil )
    content_for( :title ) { "#{ SITE_ID }: #{ this_title.nil? ? I18n.t( controller.controller_name + '.title' ) : this_title }" }
  end

  # insert a page heading from the I18n library using the current view path
  
  def form_title( t = nil )
    content_tag( :h2, t.nil? ? t( '.form_title' ) : t, class: 'form-title' )
  end

  def form_title_w( subject )
    content_tag( :h2, t( '.form_title' ) + subject, class: 'form-title' )
  end

  def form_title_w_link( subject, path, params = {} )
    content_tag( :h2, class: 'form-title' )do
      concat t( '.form_title', params )
      concat link_to( subject, path )
    end
  end

  def form_title_i( index )
    content_tag( :h2, t( '.form_titles' )[ index ], class: 'form-title' )
  end

  # display form title and optionally present sub_title

  def form_title_w_sub_title( sub_title_text )
    if sub_title_text.nil? then
      content_tag( :h2, t( '.form_title' ), class: 'form-title' )
    else
      content_tag( :h2, t( '.form_title' ), class: 'form-title-sm' ) + 
      content_tag( :p,  sub_title_text )
    end
  end

  def form_title_w_time_stamp( time_stamp = nil )
    dt = time_stamp || Time.now
    form_title_w_sub_title( t( 'time.as_at_dt', dt: db_formatted_dt( dt )))
  end

  # display some arbitrary value in an input box

  def display_value( value )
    html = String.new
    html += "<input class=\"form-control\" value=\"#{value}\" readonly />"
    html.html_safe
  end

  def display_nil
    '<input class="form-control" value="" readonly />'.html_safe
  end

  # display a check box

  def display_check_box( value )
    html = String.new
    html += "<input type=\"checkbox\" readonly disabled"
    html += " checked" if value
    html += "/>"
    html.html_safe
  end
  
  # display multiline text in a multiline textbox

  def display_lines( text, rows = DEFAULT_ROWS_TEXTAREA, cols = DEFAULT_COLS_TEXTAREA )
    html = String.new
    html += "<textarea class=\"form-control\" rows=\"#{ rows }\" cols=\"#{ cols }\" readonly>#{text}</textarea>"
    html.html_safe
  end
  
  # this could be implemented using #simple_format but I find this more
  # consistent with the other helpers here...
  
  def display_lines_w_br( text )
  	html = String.new
  	html += html_escape( text ).gsub( /(?:\n\r?|\r\n?)/, tag( 'br' ))
  	html.html_safe
  end

  # display two items in one cell, insert <br/> if necessary

  def display_two_items_w_br( text1, text2 )
    html = String.new
    html += text1.to_s
    html += tag( 'br' ) if text1 && text2
    html += text2.to_s
    html.html_safe
  end

  # display two items in one cell with a horizontal line in between

  def display_two_items_w_hr( text1, text2 )
    html = String.new
    html += text1.to_s
    unless text2.blank?
      html += raw('<hr style="margin: 0.5em 0"/>') 
      html += text2.to_s
    end
    html.html_safe
  end

  # display a boolean value with two strings; the second parameter must
  # correspond to the corresponding 'general.boolean.' settings

  def display_boolean( value, format = :yesno )
    I18n.t( 'general.boolean.' + format.to_s )[ value ? 0 : 1 ]
  end

  # create a simple option list from array:

  def select_options( an_array )
    an_array.each_with_index.collect{|v,i| [v,i]}
  end

  # format a number as id - make sure the format corresponds to the method
  # with the same name in ApplicationModel

  def some_id( id )
    id.blank? ? '' : "[#{ id }]"
  end


end
