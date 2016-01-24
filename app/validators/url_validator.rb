# This ensures that a given input field is an uniform resource locator
#
# Usage:
#
# validates :<attribute name>,
#	  url: true
#
# If the attribute is not required, add allow_blank: true

class UrlValidator < ActiveModel::EachValidator

  def validate_each( record, attribute, value )

    valid = begin
      URI.parse( value ).kind_of? URI::HTTP
    rescue URI::InvalidURIError
      false
    end
    
    unless valid
      record.errors[ attribute ] << ( options[ :message ] || 'is not a valid URL' )
    end

  end

end
