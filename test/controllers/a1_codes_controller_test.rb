class A1CodesControllerTest < ActionController::TestCase

  setup do
    @a1_code = a1_codes(:one)
    session[ :current_user_id ] = accounts( :one ).id
  end

  test 'check class_attributes'  do
    validate_feature_class_attributes FEATURE_ID_A1_CODE, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns( :a1_codes )
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create a1_code' do
    assert_difference( 'A1Code.count' ) do
      post :create, a1_code: { active: @a1_code.active, code: @a1_code.code, label: @a1_code.label, mapping: @a1_code.mapping, master: false }
    end
    assert_redirected_to a1_code_path( assigns( :a1_code ))
  end

  test 'should show a1_code' do
    get :show, id: @a1_code
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @a1_code
    assert_response :success
  end

  test 'should update a1_code' do
    patch :update, id: @a1_code, a1_code: { active: @a1_code.active, code: @a1_code.code, label: @a1_code.label, mapping: @a1_code.mapping, master: @a1_code.master }
    assert_redirected_to a1_code_path( assigns( :a1_code ))
  end

  test 'should destroy a1_code' do
    assert_difference( 'A1Code.count', -1 ) do
      delete :destroy, id: @a1_code
    end
    assert_redirected_to a1_codes_path
  end
end
