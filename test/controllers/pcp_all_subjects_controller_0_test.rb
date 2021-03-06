require 'test_helper'
class PcpAllSubjectsController0Test < ActionDispatch::IntegrationTest

  setup do
    @pcp_subject = pcp_subjects( :one )
    signon_by_user accounts( :one )
  end

  test 'check class attributes' do
    get pcp_all_subjects_path
    validate_feature_class_attributes FEATURE_ID_ALL_PCP_SUBJECTS, 
      ApplicationController::FEATURE_ACCESS_SOME,
      ApplicationController::FEATURE_CONTROL_GRP
  end

  test 'should get index' do
    get pcp_all_subjects_path
    assert_response :success
    assert_not_nil assigns( :pcp_subjects )
  end

  test 'should redirect new' do
    get new_pcp_all_subject_path
    assert_redirected_to new_pcp_subject_path
    assert_response :see_other
  end

  test 'should not create pcp_subject' do
    assert_difference( 'PcpSubject.count', 0 ) do
      post pcp_all_subjects_path( params:{ pcp_subject: {
        pcp_category_id: @pcp_subject.pcp_category_id,
        title: @pcp_subject.title, note: @pcp_subject.note,
        c_deputy_id: @pcp_subject.c_deputy_id, c_owner_id: @pcp_subject.c_owner_id,
        project_doc_id: @pcp_subject.project_doc_id,
        p_deputy_id: @pcp_subject.p_deputy_id, p_owner_id: @pcp_subject.p_owner_id,
        report_doc_id: @pcp_subject.report_doc_id }})
    end
    assert_response :forbidden
  end

  test 'should show pcp_subject' do
    get pcp_all_subject_path( id: @pcp_subject )
    assert_not_nil assigns( :pcp_curr_step )
    assert_not_nil assigns( :pcp_prev_step )
    assert_not_nil assigns( :pcp_subject )
    assert_response :success
  end

  test 'should redirect edit' do
    get edit_pcp_all_subject_path( id: @pcp_subject )
    @pcp_subjects = assigns( :pcp_subject )
    assert_not_nil @pcp_subject
    edit_pcp_subject_path( @pcp_subject )
    assert_response :see_other
  end

  test 'should not update pcp_subject' do
    patch pcp_all_subject_path( id: @pcp_subject, params:{ pcp_subject: {
      title: @pcp_subject.title, note: @pcp_subject.note,
      c_deputy_id: @pcp_subject.c_deputy_id, c_owner_id: @pcp_subject.c_owner_id,
      project_doc_id: @pcp_subject.project_doc_id,
      p_deputy_id: @pcp_subject.p_deputy_id, p_owner_id: @pcp_subject.p_owner_id,
      report_doc_id: @pcp_subject.report_doc_id }})
    assert_response :forbidden
  end

  test 'should redirect destroy' do
    assert_difference( 'PcpSubject.count', 0 ) do
      delete pcp_all_subject_path( id: @pcp_subject )
    end
    @pcp_subject = assigns( :pcp_subject )
    assert_not_nil @pcp_subject
    assert_redirected_to "/pcs/#{ @pcp_subject.id }"
    assert_response :see_other
  end
end
