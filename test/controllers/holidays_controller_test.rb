require 'test_helper'
class HolidaysControllerTest < ActionController::TestCase

  setup do
    @account = accounts( :one )
    session[ :current_user_id ] = accounts( :one ).id
    @holiday = holidays( :hdk )
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_HOLIDAYS, ApplicationController::FEATURE_ACCESS_INDEX
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :holidays       )
    assert_not_nil assigns( :country_filter )
  end

  test "should get new" do
    get :new
    assert_response :success
    assert_not_nil assigns( :country_names  )
    assert_not_nil assigns( :region_names   )
  end

  test "should add holiday" do
    get :new, id: @holiday
    assert_response :success
    assert_not_nil assigns( :holiday        )
    assert_not_nil assigns( :country_names  )
    assert_not_nil assigns( :region_names   )
  end

  test "should create holiday" do
    assert_difference('Holiday.count') do
      post :create, holiday: {
        country_name_id:  @holiday.country_name_id,
        region_name_id:   @holiday.region_name_id,
        date_from:        @holiday.date_from,
        date_until:       @holiday.date_until,
        description:      @holiday.description,
        work:             @holiday.work }
    end

    assert_redirected_to holiday_path( assigns( :holiday ))
  end

  test "should show holiday" do
    get :show, id: @holiday
    assert_response :success
    assert_not_nil assigns( :holiday        )
  end

  test "should get edit" do
    get :edit, id: @holiday
    assert_response :success
    assert_not_nil assigns( :holiday        )
    assert_not_nil assigns( :country_names  )
    assert_not_nil assigns( :region_names   )
  end

  test "should update holiday" do
    patch :update, id: @holiday, holiday: {
      country_name_id:  @holiday.country_name_id,
      region_name_id:   @holiday.region_name_id,
      date_from:        @holiday.date_from,
      date_until:       @holiday.date_until,
      description:      @holiday.description,
      work:             @holiday.work }
    assert_redirected_to holiday_path( assigns( :holiday ))
  end

  test "should destroy holiday" do
    assert_difference('Holiday.count', -1) do
      delete :destroy, id: @holiday
    end

    assert_redirected_to holidays_path
  end

  test "CSV download" do
    get :index, format: :xls
    assert_equal <<END_OF_CSV, response.body
date_from;date_until;country_name;region_name;description;work
2015-01-06;2015-01-06;GER;BY;Heilige Drei Könige (German: Epiphany);0
2015-12-24;2015-12-24;GER;;Heiligabend (German: Christmas Eve);50
2015-12-25;2015-12-27;GER;;Weihnachten (German: Christmas);0
END_OF_CSV
  end

end
