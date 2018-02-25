require 'test_helper'
class AbbreviationsControllerAccessTest < ActionDispatch::IntegrationTest

  test 'check class_attributes'  do
    signon_by_user accounts( :wop )
    get abbreviations_path
    validate_feature_class_attributes FEATURE_ID_ABBREVIATIONS, ApplicationController::FEATURE_ACCESS_VIEW
  end

  # index

  test 'index is permitted for all valid accounts' do
    signon_by_user accounts( :wop )
    get abbreviations_path
    assert_response :success
    assert_select 'h2', I18n.t( 'abbreviations.index.form_title' )
  end

  test 'should not get index' do
    get abbreviations_path
    assert_response :unauthorized
  end

  # show

  test 'show is permitted' do
    signon_by_user accounts( :wop )
    get abbreviation_path( id: abbreviations( :sag ))
    assert_response :success
  end

  test 'should not get show' do
    get abbreviation_path( id: abbreviations( :sag ))
    assert_response :unauthorized
  end

  # edit

  test 'edit is not permitted but results in cr form' do
    signon_by_user accounts( :wop )
    get edit_abbreviation_path( id: abbreviations( :sag ))
    check_for_cr
  end

  test 'should not get edit' do
    get edit_abbreviation_path( id: abbreviations( :sag ))
    assert_response :unauthorized
  end

  # new

  test 'new is not permitted but results in cr form' do
    signon_by_user accounts( :wop )
    assert_difference( 'Abbreviation.count', 0 ) { get new_abbreviation_path }
    check_for_cr
  end

  test 'should not get new' do
    assert_difference( 'Abbreviation.count', 0 ) { get new_abbreviation_path }
    assert_response :unauthorized
  end

  # update

  test 'update is not permitted but results in cr form' do
    signon_by_user accounts( :wop )
    patch abbreviation_path( id: abbreviations( :sag ))
    check_for_cr
  end

  test 'update is  not permitted' do
    patch abbreviation_path( id: abbreviations( :sag ))
    assert_response :unauthorized
  end

  # create

  test 'create is not permitted but results in cr form' do
    signon_by_user accounts( :wop )
    assert_difference( 'Abbreviation.count', 0 ) { post abbreviations_path }
    check_for_cr
  end

  test 'create is not permitted' do
    assert_difference( 'Abbreviation.count', 0 ) { post abbreviations_path }
    assert_response :unauthorized
  end

  # delete

  test 'delete is not permitted but results in cr form' do
    signon_by_user accounts( :wop )
    assert_difference( 'Abbreviation.count', 0 ) { delete abbreviation_path( id: abbreviations( :sag ))}
    check_for_cr
  end

  test 'delete is not permitted' do
    assert_difference( 'Abbreviation.count', 0 ) { delete abbreviation_path( id: abbreviations( :sag ))}
    assert_response :unauthorized
  end

end