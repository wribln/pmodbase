require 'test_helper'
class PcpSubjectsControllerTest < ActionController::TestCase

  setup do
    @pcp_subject = pcp_subjects(:one)
    session[ :current_user_id ] = accounts( :account_one ).id
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns( :pcp_subjects )
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should get release document' do
    get :show_release, id: @pcp_subject, step_no: pcp_steps( :two ).step_no
    refute_nil assigns( :pcp_step )
    refute_nil assigns( :pcp_subject )
    assert_response :success
  end

  test 'should release step' do
    assert_difference( 'PcpStep.count' ) do
      get :update_release, id: @pcp_subject
    end
    refute_nil assigns( :pcp_step )
    refute_nil assigns( :pcp_subject )
    assert_redirected_to pcp_release_doc_path( id: assigns( :pcp_subject ).id, step_no: assigns( :pcp_step ).step_no )
  end

  test 'should get history' do
    get :info, id: @pcp_subject
    assert_response :success
  end

  test 'should create pcp_subject' do
    assert_difference('PcpSubject.count') do
      post :create, pcp_subject: {
        pcp_category_id: @pcp_subject.pcp_category_id,
        title: @pcp_subject.title, note: @pcp_subject.note,
        c_deputy_id: @pcp_subject.c_deputy_id, c_owner_id: @pcp_subject.c_owner_id,
        project_doc_id: @pcp_subject.project_doc_id,
        p_deputy_id: @pcp_subject.p_deputy_id, p_owner_id: @pcp_subject.p_owner_id,
        report_doc_id: @pcp_subject.report_doc_id }
    end
    assert_not_nil assigns( :pcp_step )
    assert_redirected_to pcp_subject_path( assigns( :pcp_subject ))
  end

  test 'should show pcp_subject' do
    get :show, id: @pcp_subject
    assert_not_nil assigns( :pcp_step )
    assert_not_nil assigns( :pcp_subject )
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @pcp_subject
    assert_not_nil assigns( :pcp_step )
    assert_not_nil assigns( :pcp_subject )
    assert_response :success
  end

  test 'should update pcp_subject' do
    patch :update, id: @pcp_subject, pcp_subject: {
      title: @pcp_subject.title, note: @pcp_subject.note,
      c_deputy_id: @pcp_subject.c_deputy_id, c_owner_id: @pcp_subject.c_owner_id,
      project_doc_id: @pcp_subject.project_doc_id,
      p_deputy_id: @pcp_subject.p_deputy_id, p_owner_id: @pcp_subject.p_owner_id,
      report_doc_id: @pcp_subject.report_doc_id }
    assert_not_nil assigns( :pcp_step )
    assert_redirected_to pcp_subject_path( assigns( :pcp_subject ))
  end

  test 'should destroy pcp_subject' do
    assert_difference('PcpSubject.count', -1) do
      delete :destroy, id: @pcp_subject
    end
    assert_redirected_to pcp_subjects_path
  end
end
