# Use this scheme to save the string version of an attribute in a temporary
# storage for use during the validation process. For example, this scheme
# makes it possible to save the - possibly invalid - input string for date
# fields and use this to provide a more details error message to the user.

module StringSaver
  extend ActiveSupport::Concern

  def initialize
    @string_saver = {}
    super
  end

  protected

  # use this method to save a copy of the string value (types other than
  # String will be ignored)

  def save_string( var_name, var_string )
    if var_string.is_a? String
      @string_saver[ var_name ] = var_string
    else
      @string_saver[ var_name ].delete
    end
  end

end
