require 'test_helper'
class HolidayTest < ActiveSupport::TestCase

  test "default values of new record" do
    h = Holiday.new
    assert_nil h.date_from
    assert_nil h.date_until
    assert_nil h.country_name_id
    assert_nil h.region_name_id
    assert_nil h.description
    assert_nil h.year_period
    assert_equal 0, h.work
  end

  test "handling of invalid dates - blank" do
    h = Holiday.new
    h.date_from = " "
    assert_nil h.date_from
  end

  test "handling of invalid dates - non-date string input" do
    h = Holiday.new
    h.date_from = "schau mer mal"
    assert_not h.valid?
    assert_nil h.date_from
    assert_includes h.errors, :date_from
  end

  test "handling of invalid dates - input month name only" do
    h = Holiday.new
    h.date_from = "Apr"
    assert_not h.valid?
    assert_nil h.date_from
    assert_includes h.errors, :date_from
  end

  test "handling of invalid dates - input month and year only" do
    h = Holiday.new
    h.date_from = "June 2014"
    assert_not h.valid?
    assert_nil h.date_from
    assert_includes h.errors, :date_from
  end

  test "handling of invalid dates - input month and day" do
    h = Holiday.new
    h.date_from = "September 1st"
    assert_not h.valid?
    assert_nil h.date_from
    assert_includes h.errors, :date_from
  end

  test "handling of invalid dates - input weekday, day, year only" do
    h = Holiday.new
    h.date_from = "Thursday 2nd 2014"
    assert_not h.valid?
    assert_nil h.date_from
    assert_includes h.errors, :date_from
  end

  test "handling of invalid dates - input month and day only" do
    h = Holiday.new
    h.date_from = "1.1."
    assert_not h.valid?
    assert_nil h.date_from
    assert_includes h.errors, :date_from
  end

  test "handling of invalid dates - February 29 in a non-leap year" do
    h = Holiday.new
    h.date_from = "2015-02-29"
    assert_not h.valid?
    assert_nil h.date_from, "2015 is no leap year"
    assert_includes h.errors, :date_from
  end

  test "handling of invalid dates - February 30 in a leap year" do
    h = Holiday.new
    h.date_from = "2016-02-30"
    assert_not h.valid?
    assert_nil h.date_from
    assert_includes h.errors, :date_from
  end

  test "handling of invalid dates - no 31 days in April" do
    h = Holiday.new
    h.date_from = "2015-04-31"
    assert_not h.valid?
    assert_nil h.date_from
    assert_includes h.errors, :date_from
  end

  test "required parameters: date_from only" do
    h = Holiday.new
    assert_not h.valid?
    assert_includes h.errors, :date_from    
  end

  test "automatically set date_until when only date_from exists" do
    h = Holiday.new
    h.date_from = "2015-4-3"
    assert_not h.valid?
    refute_includes h.errors, :date_from
    refute_includes h.errors, :date_until
    assert_equal h.date_from, h.date_until
    assert_equal 2015, h.date_from.year
  end

  test "date_until must be past date_from" do
    h = Holiday.new
    h.date_from  = "2015-4-3"
    h.date_until = "2015-4-2"
    assert_not h.valid?
    assert_includes h.errors, :date_until
  end

  test "date_from and date_until ok" do
    h = Holiday.new
    h.date_from  = "2015-4-3"
    h.date_until = "2015-4-4"
    assert_not h.valid?
    refute_includes h.errors, :date_from
    refute_includes h.errors, :date_until
    assert_equal 2015, h.date_from.year
  end

  test "both dates must be within the same year" do
    h = Holiday.new
    h.date_from  = "2015-12-24"
    h.date_until = "2016-1-6"
    assert_not h.valid?
    assert_includes h.errors, :date_until
  end

  test "required parameters: date_from" do
    h = holidays( :hdk )
    h.date_from = nil
    assert_not h.valid?
    assert_includes h.errors, :date_from
  end

  test "required parameters: description" do
    h = holidays( :hdk )
    h.description = nil
    assert_not h.valid?
    assert_includes h.errors, :description
  end

  test "required parameters: work" do
    h = holidays( :hdk )
    h.work = nil
    assert_not h.valid?
    assert_includes h.errors, :work
  end

  test "required parameters: country_name_id" do
    h = holidays( :hdk )
    h.country_name_id = nil
    assert_not h.valid?
    assert_includes h.errors, :country_name
  end

  test "not required parameter: region_name_id" do
    h = holidays( :hdk )
    h.region_name_id = nil
    assert h.valid?
  end

  test "range of valid values: work" do
    h = holidays( :hdk )
    h.work = -1
    assert_not h.valid?
    assert_includes h.errors, :work
    h.work = 101
    assert_not h.valid?
    assert_includes h.errors, :work
    h.work = 0.5
    assert_not h.valid?
    assert_includes h.errors, :work
  end

  test "country reference must exist" do
    h = holidays( :hdk )
    h.country_name_id = nil
    assert_not h.valid?
    assert_includes h.errors, :country_name

    h.country_name_id = 0
    assert_not h.valid?
    assert_includes h.errors, :country_name
  end

  test "region reference must exist" do
    h =  holidays( :hdk )
    h.region_name_id = 0
    assert_not h.valid?
    assert_includes h.errors, :region_name_id
  end

  test "period_to_s" do
    h = holidays( :hdk )
    h.date_until = h.date_from = "2015-4-3"
    assert h.valid?
    assert_equal h.period_to_s, Date.new( 2015, 4, 3 ).to_formatted_s( :db_date )
    h.date_until = h.date_from + 1
    assert_equal h.period_to_s, "#{ Date.new( 2015, 4, 3 ).to_formatted_s( :db_date )} - #{ Date.new( 2015, 4, 4 ).to_formatted_s( :db_date )} (2)"
    h.date_from = nil
    assert_equal h.period_to_s, '', 'date_from nil'
    h.date_from = h.date_until
    h.date_until = nil
    assert_equal h.period_to_s, '', 'date_until nil'
    h.date_from = nil
    assert_equal h.period_to_s, '', 'both dates nil'
  end

  test "region_to_s" do
    h = holidays( :hdk )
    hc = h.country_name_id
    hr = h.region_name_id
    assert_equal h.region_to_s, 'GER-BY'
    h.region_name_id = nil
    assert_equal h.region_to_s, 'GER'
    h.region_name_id = hr
    h.country_name_id = nil
    assert_equal h.region_to_s, '-BY'
    h.region_name_id = nil
    assert_equal h.region_to_s, ''
  end

  test "trimming of description text" do
    h = Holiday.new
    h.description = "  a  description  "
    assert_equal h.description,"a description"
  end

end
