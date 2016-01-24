# The mixin implements various, generally used methods in controllers.

module ControllerMethods
  extend ActiveSupport::Concern 

  # prepare header for fileformats other than standard html, json, ...

  def set_header( p_type, filename )
    case p_type
    when :doc
      headers[ 'Content-Type' ] = 'application/vnd.ms-word; charset=UTF-8'
      headers[ 'Content-Disposition' ] = "attachment; filename=\"#{ filename }\""
      headers[ 'Cache-Control' ] = ''
    when :xls
      headers[ 'Content-Type' ] = 'application/vnd.ms-excel; charset=UTF-8'
      headers[ 'Content-Disposition' ] = "attachment; filename=\"#{ filename }\""
      headers[ 'Cache-Control' ] = ''
    end
  end

end # ControllerMethods