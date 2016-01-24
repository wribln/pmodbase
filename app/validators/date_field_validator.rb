# The task of this class is to validate a date input field with better error
# error messages based on the original user input: Without this validator,
# Rails will only accept valid dates, ill-formated (i.e. incomplete) or 
# invalid (non-existing) dates will quietly type-casted into nil values when
# storing them into the attribute.
#
# This validator can be used as follows:
#
# validates :<attribute name>,
#   date_field: { presence: true|false }
#
# where presence acts like the standard presence validator: You can use the
# standard validation for presence but this will cause an extra error message
# to be generated when a required date field is ill-formated or invalid.
#
# Ill-formated date fields are those which do not contain the complete 
# information needed to translate the string into a valid date, i.e. we need
# (at least) the year, month, and day. Errors like this will be detected by
# _parse.
#
# Invalid dates are those which pass _parse but will fail on valid_date?
#
# Note: in the respective forms, use text_field for date variables which are
#       to be validated here.

class DateFieldValidator < ActiveModel::EachValidator

  def validate_each( record, attribute, value )

    # when a date has been successfully type-casted into a date, we are done:

    return unless value.nil?

    # process presence based on the original value

    original_value = record.read_attribute_before_type_cast( attribute )
    if original_value.blank?
      record.errors.add( attribute, :blank ) if options[ :presence ]
      return
    end

    # ignore any other value but String

    return unless original_value.is_a? String

    # _parse must return some useful values

    parsed_value = Date._parse( original_value )
    unless [ :year, :mon, :mday ].all? { |key| parsed_value.has_key?( key ) }
      record.errors.add( attribute, ( options[ :message ] || I18n.t( 'validators.date_field.bad_syntax', bad_date: original_value )))
      return
    end

    # valid_date? must return true

    unless Date.valid_date?( parsed_value[ :year ], parsed_value[ :mon ], parsed_value[ :mday ])
      record.errors.add( attribute, ( options[ :message ] || I18n.t( 'validators.date_field.bad_date', bad_date: original_value )))
      return
    end

  end

end
