require 'test_helper'
class CfrFileTypesControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
    @cfr_file_type = cfr_file_types( :one )
  end

  test 'should get index' do
    get cfr_file_types_path
    assert_response :success
    assert_not_nil assigns( :cfr_file_types )
  end

  test 'should get new' do
    get new_cfr_file_type_path
    assert_response :success
  end

  test 'should create cfr_file_type single extension' do
    assert_difference( 'CfrFileType.count' ) do
      post cfr_file_types_path, params:{ cfr_file_type: { extensions: 'xyz', label: 'XYZ' }}
    end
    assert_redirected_to cfr_file_type_path( assigns( :cfr_file_type ))
  end

  test 'should create cfr_file_type list of extensions' do
    assert_difference( 'CfrFileType.count' ) do
      post cfr_file_types_path, params:{ cfr_file_type: { extensions: 'abc,def,ghi', label: 'A to I' }}
    end
    assert_redirected_to cfr_file_type_path( assigns( :cfr_file_type ))
  end

  test 'should show cfr_file_type' do
    get cfr_file_type_path( id: @cfr_file_type )
    assert_response :success
  end

  test 'should get edit' do
    get edit_cfr_file_type_path( id: @cfr_file_type )
    assert_response :success
  end

  test 'should update cfr_file_type' do
    patch cfr_file_type_path( id: @cfr_file_type, params:{ cfr_file_type: { extensions: @cfr_file_type.extensions + ',xxx', label: @cfr_file_type.label }})
    assert_redirected_to cfr_file_type_path( assigns( :cfr_file_type ))
  end

  test 'should destroy cfr_file_type' do
    assert_difference('CfrFileType.count', -1) do
      delete cfr_file_type_path( id: @cfr_file_type )
    end

    assert_redirected_to cfr_file_types_path
  end
end
