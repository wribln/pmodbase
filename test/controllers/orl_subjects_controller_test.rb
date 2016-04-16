require 'test_helper'

class OrlSubjectsControllerTest < ActionController::TestCase
  setup do
    @orl_subject = orl_subjects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:orl_subjects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create orl_subject" do
    assert_difference('OrlSubject.count') do
      post :create, orl_subject: { desc: @orl_subject.desc, notes: @orl_subject.notes, o_deputy_id: @orl_subject.o_deputy_id, o_owner_id: @orl_subject.o_owner_id, project_doc_id: @orl_subject.project_doc_id, r_deputy_id: @orl_subject.r_deputy_id, r_owner_id: @orl_subject.r_owner_id, report_doc_id: @orl_subject.report_doc_id }
    end

    assert_redirected_to orl_subject_path(assigns(:orl_subject))
  end

  test "should show orl_subject" do
    get :show, id: @orl_subject
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @orl_subject
    assert_response :success
  end

  test "should update orl_subject" do
    patch :update, id: @orl_subject, orl_subject: { desc: @orl_subject.desc, notes: @orl_subject.notes, o_deputy_id: @orl_subject.o_deputy_id, o_owner_id: @orl_subject.o_owner_id, project_doc_id: @orl_subject.project_doc_id, r_deputy_id: @orl_subject.r_deputy_id, r_owner_id: @orl_subject.r_owner_id, report_doc_id: @orl_subject.report_doc_id }
    assert_redirected_to orl_subject_path(assigns(:orl_subject))
  end

  test "should destroy orl_subject" do
    assert_difference('OrlSubject.count', -1) do
      delete :destroy, id: @orl_subject
    end

    assert_redirected_to orl_subjects_path
  end
end
