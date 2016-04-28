require 'test_helper'
class PcpSubjectsController1Test < ActionController::TestCase
  tests PcpSubjectsController

  setup do
    @pcp_subject = pcp_subjects( :one )
    @account_id = accounts( :account_one ).id
    session[ :current_user_id ] = @account_id
  end

  test 'chain of Releases' do

    # create new subject

    assert_difference([ 'PcpSubject.count', 'PcpStep.count' ], 1 )do
    post :create, pcp_subject: {
        pcp_category_id: @pcp_subject.pcp_category_id,
        title: 'Test Document',
        project_doc_id: 'PROJECT-DOC-ID',
        report_doc_id: 'REPORT-DOC-ID' }
    end
    @new_pcp_subject = assigns( :pcp_subject )
    @new_pcp_step = @new_pcp_subject.pcp_steps.first
    assert_equal 0, @new_pcp_step.step_no
    assert_redirected_to pcp_subject_path( @new_pcp_subject )

    # update for release to commenting party

    assert_no_difference([ 'PcpSubject.count', 'PcpStep.count' ])do
      patch :update, id: @new_pcp_subject, 
        pcp_subject: { p_owner_id: @account_id,
        pcp_steps_attributes: {  '0' => { id: @new_pcp_step.id, subject_version: '0', report_version: 'A' }}}
    end
    @new_pcp_subject = assigns( :pcp_subject )
    @new_pcp_step = @new_pcp_subject.pcp_steps.first
    assert_equal 0, @new_pcp_step.step_no
    assert_equal '0', @new_pcp_step.subject_version
    assert_equal 'A', @new_pcp_step.report_version

    # perform release

    assert @new_pcp_subject.user_is_owner_or_deputy?( @account_id, @new_pcp_step.acting_group_index )
    assert_difference( 'PcpStep.count', 1 )do
      get :update_release, id: @new_pcp_subject
    end
    @new_pcp_subject = assigns( :pcp_subject )
    @new_pcp_step = @new_pcp_subject.pcp_steps.first
    assert_equal 1, @new_pcp_step.step_no

    # update for release to presenting party

    assert_no_difference([ 'PcpSubject.count', 'PcpStep.count' ])do
      patch :update, id: @new_pcp_subject, 
        pcp_subject: { c_owner_id: @account_id,
        pcp_steps_attributes: {  '0' => { id: @new_pcp_step.id, report_version: 'B' }}}
    end
    @new_pcp_subject = assigns( :pcp_subject )
    @new_pcp_step = @new_pcp_subject.pcp_steps.first
    assert_equal 1, @new_pcp_step.step_no


  end


end