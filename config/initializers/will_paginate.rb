require 'will_paginate/view_helpers/action_view'
module WillPaginate
  module ActionView
    def will_paginate( collection = nil, options = {})
      options[ :renderer ] ||= BootstrapLinkRenderer
      options[ :previous_label ] = '&laquo;'.freeze
      options[ :next_label ] = '&raquo;'.freeze
      super.try :html_safe
    end

    class BootstrapLinkRenderer < LinkRenderer

      protected

      def html_container( html )
        tag( :ul, html, container_attributes )
      end
  
      def page_number( page )
        tag( :li, link( page, page, rel: rel_value( page )), class: ( 'active' if page == current_page ))
      end
  
      def previous_or_next_page( page, text, classname )
        tag( :li, link( text, page || '#' ), class: [ classname[ 0..3 ], classname, ( 'disabled' unless page )].join(' '))
      end
  
      def gap
        tag( :li, link( super, '#' ), class: 'disabled' )
      end

    end

  end

end