require 'test_helper'
class PcpSubjectsController2Test < ActionController::TestCase
  tests PcpSubjectsController

  # USER HAS NO PERMISSION AT ALL

  setup do
    @pcp_subject = pcp_subjects( :one )
    @account_id = accounts( :account_wop ).id
    session[ :current_user_id ] = @account_id
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get new' do
    get :new
    check_for_cr
  end

  test 'should get release document' do
    get :show_release, id: @pcp_subject, step_no: 0
    check_for_cr
  end

  test 'should release step' do
    assert_no_difference( 'PcpStep.count' ) do
      get :update_release, id: @pcp_subject
    end
    check_for_cr
  end

  test 'should get history' do
    get :show_history, id: @pcp_subject
    check_for_cr
  end

  test 'should create pcp_subject' do
    assert_no_difference( 'PcpSubject.count' ) do
      post :create, pcp_subject: {
        pcp_category_id: @pcp_subject.pcp_category_id,
        title: @pcp_subject.title, note: @pcp_subject.note,
        c_deputy_id: @pcp_subject.c_deputy_id, c_owner_id: @pcp_subject.c_owner_id,
        project_doc_id: @pcp_subject.project_doc_id,
        p_deputy_id: @pcp_subject.p_deputy_id, p_owner_id: @pcp_subject.p_owner_id,
        report_doc_id: @pcp_subject.report_doc_id }
    end
    check_for_cr
  end

  test 'should show pcp_subject' do
    get :show, id: @pcp_subject
    check_for_cr
  end

  test 'should get edit' do
    get :edit, id: @pcp_subject
    check_for_cr
  end

  test 'should update pcp_subject' do
    patch :update, id: @pcp_subject, pcp_subject: {
      title: @pcp_subject.title, note: @pcp_subject.note,
      c_deputy_id: @pcp_subject.c_deputy_id, c_owner_id: @pcp_subject.c_owner_id,
      project_doc_id: @pcp_subject.project_doc_id,
      p_deputy_id: @pcp_subject.p_deputy_id, p_owner_id: @pcp_subject.p_owner_id,
      report_doc_id: @pcp_subject.report_doc_id }
    check_for_cr
  end

  test 'should destroy pcp_subject' do
    assert_no_difference( 'PcpSubject.count' ) do
      delete :destroy, id: @pcp_subject
    end
    check_for_cr
  end

end
