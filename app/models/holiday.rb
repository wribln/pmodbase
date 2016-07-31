# Note: This model contains a column 'year_period' containing the year of the
# 'date_from'field. This is redundant but makes filtering in Rails much.
# easier. This field is set by '#date_combination' when all other validations
# have passed successfully.

class Holiday < ActiveRecord::Base
  include ApplicationModel
  include CountryNameCheck
  include RegionNameCheck
  include Filterable

  belongs_to :country_name, -> { readonly }, inverse_of: :holidays
  belongs_to :region_name,  -> { readonly }, inverse_of: :holidays

  validates :date_from,
    date_field: { presence: true }

  validates :date_until,
    date_field: { presence: false }

  validates :country_name,
    presence: true

  validates :description,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  validates :work,
    presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..100 }

  validate :given_country_name_exists
  validate :given_region_name_exists
  validate :date_combination_valid

  default_scope { order( date_from: :asc, country_name_id: :asc )}
  scope :ff_id,       -> ( i ){ where id: i }
  scope :ff_country,  -> ( c ){ where country_name: c }
  scope :ff_year,     -> ( y ){ where year_period:  y }
  scope :ff_desc,     -> ( d ){ where( 'description LIKE ?', "%#{ d }%" )}

  # date_combination_valid checks if date_until is correct in relationship
  # to date_from, i.e. date_until must be >= date_from, if date_until is
  # nil, it will be set to date_from. Furthermore, check if both dates
  # - if valid so far - are within the same year.

  def date_combination_valid

    # just make sure we work on something valid and existing

    return false unless date_from?

    set_nil_default( :date_until, date_from )

    if date_until < date_from
      errors.add( :date_until, I18n.t( 'holidays.msg.bad_period' ))
      return false
    end

    if date_from.year != date_until.year
      errors.add( :date_until, I18n.t( 'holidays.msg.bad_years' ))
      return false
    end

    # all tests passed

    write_attribute( :year_period, date_from.year )
    return true
  end

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks

  def description=( text )
    write_attribute( :description, AppHelper.clean_up( text ))
  end

  # helper functions

  def period_to_s
    if not ( date_from? and date_until? )
      ''
    elsif date_from == date_until
      date_from.to_formatted_s( :project_date )
    else
      "#{ date_from.to_formatted_s( :project_date )} - #{ date_until.to_formatted_s( :project_date )} (#{( date_until - date_from + 1 ).to_i })"
    end
  end

  def region_to_s
    "#{ country_name.code if country_name_id? }" << ( "-#{ region_name.code }" if region_name_id? ).to_s
  end

end
