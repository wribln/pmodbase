require 'test_helper'
class PeopleControllerTest < ActionDispatch::IntegrationTest

  setup do
    @person = people( :person_one )
    signon_by_user accounts( :one )
  end

  test 'check class_attributes'  do
    get people_path
    validate_feature_class_attributes FEATURE_ID_PEOPLE, ApplicationController::FEATURE_ACCESS_SOME
  end

  test 'should get index' do
    get people_path
    assert_response :success
    assert_not_nil assigns(:people)
  end

  test 'should get new' do
    get new_person_path
    assert_response :success
  end

  test 'should create person' do
    assert_difference('Person.count') do
      post people_path( params:{ person: { formal_name: @person.formal_name, email: 'new@company.com' }})
    end
    assert_response :success
  end

  test 'should show person' do
    get person_path( id: @person )
    assert_response :success
  end

  test 'should get edit' do
    get edit_person_path( id: @person )
    assert_response :success
  end

  test 'should update person' do
    patch person_path( id: @person, params:{ person: { formal_name: @person.formal_name, email: 'new@company.com' }})
    assert_response :success
  end

  test 'should destroy person' do
    assert_difference('Person.count', -1) do
      delete person_path( id: @person )
    end
    assert_redirected_to people_path
  end
end
