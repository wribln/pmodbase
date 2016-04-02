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
  
  def page_title
    create_page_title I18n.t( controller.controller_name + '.title' )
  end

  def create_page_title( t )
    content_for( :title ) { "#{ SITE_NAME }: #{ t }" }
  end

  # insert a page heading from the I18n library using the current view path
  
  def form_title
    content_tag( :h2, t( '.form_title' ), class: 'form-title' )
  end

  def form_title_w( subject )
    content_tag( :h2, t( '.form_title' ) + subject, class: 'form-title' )
  end

  def form_title_w_link( subject, path )
    content_tag( :h2, class: 'form-title' )do
      concat t( '.form_title' )
      concat link_to( subject, path )
    end
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

  # display some arbitrary value in an input box

  def display_value( value )
    html = ""
    html += "<input class=\"form-control\" value=\"#{value}\" readonly />"
    html.html_safe
  end
  
  # display multiline text in a multiline textbox

  def display_lines( text, rows = DEFAULT_ROWS_TEXTAREA, cols = DEFAULT_COLS_TEXTAREA )
    html = ""
    html += "<textarea class=\"form-control\" rows=\"#{ rows }\" cols=\"#{ cols }\" readonly>#{text}</textarea>"
    html.html_safe
  end
  
  # this could be implemented using #simple_format but I find this more
  # consistent with the other helpers here...
  
  def display_lines_w_br( text )
  	html = ""
  	html += h( text ).gsub( /(?:\n\r?|\r\n?)/, "<br>" )
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
