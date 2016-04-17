require 'test_helper'
class PcpSubjectsControllerTest < ActionController::TestCase

  setup do
    @pcp_subject = pcp_subjects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pcp_subjects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pcp_subject" do
    assert_difference('PcpSubject.count') do
      post :create, pcp_subject: {
        desc: @pcp_subject.desc, notes: @pcp_subject.notes,
        c_deputy_id: @pcp_subject.c_deputy_id, c_owner_id: @pcp_subject.c_owner_id,
        project_doc_id: @pcp_subject.project_doc_id,
        p_deputy_id: @pcp_subject.p_deputy_id, p_owner_id: @pcp_subject.p_owner_id,
        report_doc_id: @pcp_subject.report_doc_id }
    end

    assert_redirected_to pcp_subject_path(assigns(:pcp_subject))
  end

  test "should show pcp_subject" do
    get :show, id: @pcp_subject
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @pcp_subject
    assert_response :success
  end

  test "should update pcp_subject" do
    patch :update, id: @pcp_subject, pcp_subject: {
      desc: @pcp_subject.desc, notes: @pcp_subject.notes,
      c_deputy_id: @pcp_subject.c_deputy_id, c_owner_id: @pcp_subject.c_owner_id,
      project_doc_id: @pcp_subject.project_doc_id,
      p_deputy_id: @pcp_subject.p_deputy_id, p_owner_id: @pcp_subject.p_owner_id,
      report_doc_id: @pcp_subject.report_doc_id }
    assert_redirected_to pcp_subject_path(assigns(:pcp_subject))
  end

  test "should destroy pcp_subject" do
    assert_difference('PcpSubject.count', -1) do
      delete :destroy, id: @pcp_subject
    end

    assert_redirected_to pcp_subjects_path
  end
end
