module HelpPagesHelper

  def help_title( text )
    content_for( :title ) { "#{SITE_ID}: #{ text }" }
    content_for( :topic ) { text }
  end

  def help_header( text = content_for( :topic ))
    content_tag( :h1, text, { class: 'page-header' })
  end

  def link_to_help( title, text = nil, html_options = {} )
    html_options[ :target ] = '_blank' if params[ :controller ] != 'help_pages'
    link_to( text.nil? ? title : text, "#{ help_path }/#{ title.downcase }", html_options )
  end

  def help_param( text )
    content_tag( :strong, text )
  end

  # use this to highlight/format a term in help texts, for example specific
  # values of parameters used in running text

  def help_term( text )
    content_tag( :u, text )
  end

  # use this to hightlight/format a value of a help parameter

  def help_value( text )
    content_tag( :em, text )
  end

  def help_footer( feature_id )
    render partial: 'shared/footer', locals: { feature_identifier: feature_id, cr_details: "help_on_#{ params[ :title ]}" } 
  end

end
