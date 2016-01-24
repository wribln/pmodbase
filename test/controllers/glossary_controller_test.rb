require 'test_helper'
class GlossaryItemsControllerTest < ActionController::TestCase

  setup do
    session[ :current_user_id ] = accounts( :account_one ).id
    @glossary_item = glossary_items( :one )
  end

  test "check class_attributes"  do
    validate_feature_class_attributes FEATURE_ID_GLOSSARY, ApplicationController::FEATURE_ACCESS_INDEX
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns( :glossary_items )
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create glossary_item" do
    assert_difference( 'GlossaryItem.count' ) do
      post :create, glossary_item: {
        code:         @glossary_item.code,
        description:  @glossary_item.description,
        term:         @glossary_item.term,
        reference_id: @glossary_item.reference_id }
    end
    assert_redirected_to glossary_item_path( assigns( :glossary_item ))
  end

  test "should show glossary_item" do
    get :show, id: @glossary_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @glossary_item
    assert_response :success
  end

  test "should update glossary_item" do
    patch :update, id: @glossary_item, glossary_item: { code: @glossary_item.code, description: @glossary_item.description, term: @glossary_item.term }
    assert_redirected_to glossary_item_path(assigns(:glossary_item))
  end

  test "should destroy glossary_item" do
    assert_difference('GlossaryItem.count', -1) do
      delete :destroy, id: @glossary_item
    end

    assert_redirected_to glossary_items_path
  end

  test "CSV download" do
    get :index, format: :xls
    assert_equal <<END_OF_CSV, response.body
term;code;description;reference_code
A Glossary Term;AGT;This is a glossary term.;REFONE
END_OF_CSV
  end

end
