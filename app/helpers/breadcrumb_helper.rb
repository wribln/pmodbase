# formats the controller's breadcrumb_list: this module is closely related
# to the breadcrumb_list mixin for the pmodbase feature controllers where
# the breadcrumb_list is generated

module BreadcrumbHelper

  def breadcrumbs
    return if session[ :keep_base_open ]
    r = ''
    controller.breadcrumbs_to_here.try( :each ) do |i|
      i == breadcrumbs_to_here.last ? options = { class: 'active' } : nil
      if i.first.nil? then # show action only (normally last)
        r += content_tag( :li, I18n.t( 'button_label.' + i.second.to_s ), options )
      elsif i.second.nil? # show text only, no path
        r += content_tag( :li, I18n.t( i.first.to_s + '.title' ), options )
      else  # show text with path
        r += content_tag( :li, link_to( I18n.t( i.first.to_s + '.title'), i.second, options ))
      end
    end
    s = tag( 'div', { class: 'row hidden-print' })
    s += content_tag( :ol, r.html_safe, class: 'breadcrumb col-sm-11' ) unless r.empty?
    s += content_tag( :ol, content_tag( :li, link_to_help( controller.feature_help_file, t( 'button_label.help' )), class: 'breadcrumb col-sm-1' ))
    s += tag( '/div', {}, true )
  end

  # use this method to determine whether a new window/tab should be opened 

  def target_window
    session[ :keep_base_open ] ? '_blank' : '_self'
  end

  def helpcrumbs
    return if session[ :keep_base_open ]
    r = ''
    r += content_tag( :li, link_to_help( :help_pages, t( 'help_pages.main_help' )))
    r += content_tag( :li, content_for( :topic ))
    content_tag( :ol, r.html_safe, class: 'breadcrumb' ) unless r.empty?
  end

end