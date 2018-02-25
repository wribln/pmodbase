require 'test_helper'
class GlossaryItemsControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
    @glossary_item = glossary_items( :one )
  end

  test 'check class_attributes'  do
    get glossary_items_path
    validate_feature_class_attributes FEATURE_ID_GLOSSARY, ApplicationController::FEATURE_ACCESS_VIEW
  end

  test 'should get index' do
    get glossary_items_path
    assert_response :success
    assert_not_nil assigns( :glossary_items )
  end

  test 'should get new' do
    get new_glossary_item_path
    assert_response :success
  end

  test 'should create glossary_item' do
    assert_difference( 'GlossaryItem.count' ) do
      post glossary_items_path( params:{ glossary_item: {
        code:         @glossary_item.code,
        description:  @glossary_item.description,
        term:         @glossary_item.term,
        cfr_record_id: @glossary_item.cfr_record_id }})
    end
    assert_redirected_to glossary_item_path( assigns( :glossary_item ))
  end

  test 'should show glossary_item' do
    get glossary_item_path( id: @glossary_item )
    assert_response :success
  end

  test 'should get edit' do
    get edit_glossary_item_path( id: @glossary_item )
    assert_response :success
  end

  test 'should update glossary_item' do
    patch glossary_item_path( id: @glossary_item, params:{ glossary_item: { code: @glossary_item.code, description: @glossary_item.description, term: @glossary_item.term }})
    assert_redirected_to glossary_item_path(assigns(:glossary_item))
  end

  test 'should destroy glossary_item' do
    assert_difference('GlossaryItem.count', -1) do
      delete glossary_item_path( id: @glossary_item )
    end
    assert_redirected_to glossary_items_path
  end

  test 'CSV download' do
    get glossary_items_path( format: :xls )
    assert_equal <<END_OF_CSV, response.body
term;code;description;cfr_record_id
A Glossary Term;AGT;This is a glossary term.;just a title
END_OF_CSV
  end

end
