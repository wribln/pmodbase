require 'test_helper'
class PcpAllSubjectsController2Test < ActionDispatch::IntegrationTest

  # USER HAS NO PERMISSION AT ALL

  setup do
    @pcp_subject = pcp_subjects( :one )
    signon_by_user accounts( :wop )
  end

  test 'should get index' do
    get pcp_all_subjects_path
    check_for_cr
  end

  test 'should get new' do
    get new_pcp_all_subject_path
    check_for_cr
  end

  test 'should create pcp_subject' do
    assert_no_difference( 'PcpSubject.count' ) do
      post pcp_all_subjects_path( params:{ pcp_subject: {
        pcp_category_id: @pcp_subject.pcp_category_id,
        title: @pcp_subject.title, note: @pcp_subject.note,
        c_deputy_id: @pcp_subject.c_deputy_id, c_owner_id: @pcp_subject.c_owner_id,
        project_doc_id: @pcp_subject.project_doc_id,
        p_deputy_id: @pcp_subject.p_deputy_id, p_owner_id: @pcp_subject.p_owner_id,
        report_doc_id: @pcp_subject.report_doc_id }})
    end
    check_for_cr
  end

  test 'should show pcp_subject' do
    get pcp_all_subject_path( id: @pcp_subject )
    check_for_cr
  end

  test 'should get edit' do
    get edit_pcp_all_subject_path( id: @pcp_subject )
    check_for_cr
  end

  test 'should update pcp_subject' do
    patch pcp_all_subject_path( id: @pcp_subject, params:{ pcp_subject: {
      title: @pcp_subject.title, note: @pcp_subject.note,
      c_deputy_id: @pcp_subject.c_deputy_id, c_owner_id: @pcp_subject.c_owner_id,
      project_doc_id: @pcp_subject.project_doc_id,
      p_deputy_id: @pcp_subject.p_deputy_id, p_owner_id: @pcp_subject.p_owner_id,
      report_doc_id: @pcp_subject.report_doc_id }})
    check_for_cr
  end

  test 'should destroy pcp_subject' do
    assert_no_difference( 'PcpSubject.count' ) do
      delete pcp_all_subject_path( id: @pcp_subject )
    end
    check_for_cr
  end

end
