require 'test_helper'
class CfrFileTypesControllerTest < ActionController::TestCase

  setup do
    @cfr_file_type = cfr_file_types(:one)
    @account = accounts( :account_one )
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns( :cfr_file_types )
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create cfr_file_type single extension' do
    assert_difference( 'CfrFileType.count' ) do
      post :create, cfr_file_type: { extensions: 'xyz', label: 'XYZ' }
    end
    assert_redirected_to cfr_file_type_path( assigns( :cfr_file_type ))
  end

  test 'should create cfr_file_type list of extensions' do
    assert_difference( 'CfrFileType.count' ) do
      post :create, cfr_file_type: { extensions: 'abc,def,ghi', label: 'A to I' }
    end
    assert_redirected_to cfr_file_type_path( assigns( :cfr_file_type ))
  end

  test 'should show cfr_file_type' do
    get :show, id: @cfr_file_type
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @cfr_file_type
    assert_response :success
  end

  test 'should update cfr_file_type' do
    patch :update, id: @cfr_file_type, cfr_file_type: { extensions: @cfr_file_type.extensions + ',xxx', label: @cfr_file_type.label }
    assert_redirected_to cfr_file_type_path( assigns( :cfr_file_type ))
  end

  test 'should destroy cfr_file_type' do
    assert_difference('CfrFileType.count', -1) do
      delete :destroy, id: @cfr_file_type
    end

    assert_redirected_to cfr_file_types_path
  end
end
