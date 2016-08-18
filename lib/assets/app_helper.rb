# Contains application helper modules, a general function library.

module AppHelper

  # clean_up removes leading and trailing whitespace, plus duplicate blanks
  # from a [text] string, optionally truncates the string to a given length
  # of [max_chars].
  #
  # squish cannot be used here as I want to preserve intermediate linefeeds.
  #
  # Returns is_empty for empty strings or results from useless parameters.

  def clean_up( text, max_chars = 0, is_empty = nil )
    result = ''
    if text.class == String then
      result = text.strip.squeeze(' ')
      if max_chars && ( max_chars > 0 )
        result = result[ 0..( max_chars - 1 )]
      end
    end
    result.blank? ? is_empty : result
  end
  module_function :clean_up

  # the following function creates a hash to be used for a where condition:
  # the first parameter is a string with comma-separated values, the 
  # subsequent parameters must by symbols to map these values to. Empty
  # values and spare parameters will be ignored.

  def map_values( value_list, *p )
    v = value_list.split(',')
    n = ( v.length < p.length ) ? v.length : p.length
    h = {}
    p[ 0..( n - 1 )].each_index { |i| h[ p[ i ]] = v[ i ] unless v[ i ].empty? }
    return h
  end
  module_function :map_values

  # fix string so it fits into the available space

  def fix_string( text, max_chars = 255, right = 0 )
    if text.length > max_chars then
      "#{ text[ 0..( max_chars - right - 3 )] }...#{ text[ -right..-1 ]}"
    else
      text
    end
  end
  module_function :fix_string

end
