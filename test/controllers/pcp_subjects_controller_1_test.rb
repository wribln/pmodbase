require 'test_helper'
class PcpSubjectsController1Test < ActionController::TestCase
  tests PcpSubjectsController

  setup do
    @pcp_subject = pcp_subjects( :one )
    @account_id = accounts( :account_one ).id
    session[ :current_user_id ] = @account_id
  end

  [ '1', '4' ].each do |final_assessment|

  test "Chain of Releases: Final Assessment: #{ final_assessment }" do

    # create new subject

    assert_difference([ 'PcpSubject.count', 'PcpStep.count' ], 1 )do
      post :create, pcp_subject: {
        pcp_category_id: @pcp_subject.pcp_category_id,
        title: 'Test Document',
        project_doc_id: 'PROJECT-DOC-ID',
        report_doc_id: 'REPORT-DOC-ID' }
      assert_response :redirect
    end
    @new_pcp_subject = assigns( :pcp_subject )
    @new_pcp_step = @new_pcp_subject.pcp_steps.first
    assert_equal 0, @new_pcp_step.step_no
    assert_redirected_to pcp_subject_path( @new_pcp_subject )

    # update for release to commenting party - try without report_version

    assert_no_difference([ 'PcpSubject.count', 'PcpStep.count' ])do
      patch :update, id: @new_pcp_subject, 
        pcp_subject: { p_owner_id: @account_id,
        pcp_steps_attributes: {  '0' => { id: @new_pcp_step.id, subject_version: '0' }}}
    end
    @new_pcp_subject = assigns( :pcp_subject )
    @new_pcp_step = @new_pcp_subject.pcp_steps.first

    # attempt release: must fail with missing report version

    assert @new_pcp_subject.user_is_owner_or_deputy?( @account_id, @new_pcp_step.acting_group_index )
    assert_equal 2, @new_pcp_step.release_type, @new_pcp_step.errors.messages
    assert_no_difference( 'PcpStep.count' )do
      get :update_release, id: @new_pcp_subject
    end
    @new_pcp_subject = assigns( :pcp_subject )
    @new_pcp_step = @new_pcp_subject.pcp_steps.first
    assert_equal 0, @new_pcp_step.step_no

    # update for release to commenting part - provide report_version

    assert @new_pcp_subject.user_is_owner_or_deputy?( @account_id, @new_pcp_step.acting_group_index )
    assert_no_difference([ 'PcpSubject.count', 'PcpStep.count' ])do
      patch :update, id: @new_pcp_subject, 
        pcp_subject: { p_owner_id: @account_id,
        pcp_steps_attributes: {  '0' => { id: @new_pcp_step.id, report_version: 'A' }}}
    end
    @new_pcp_subject = assigns( :pcp_subject )
    @new_pcp_step = @new_pcp_subject.pcp_steps.first
    assert_equal 0, @new_pcp_step.step_no
    assert_equal 'A', @new_pcp_step.report_version

    # perform first release: presenting to commenting party

    assert @new_pcp_subject.user_is_owner_or_deputy?( @account_id, @new_pcp_step.acting_group_index )
    assert_equal 0, @new_pcp_step.release_type, @new_pcp_step.errors.messages
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
        pcp_steps_attributes: {  '0' => { id: @new_pcp_step.id, report_version: 'B', new_assmt: 2 }}}
    end
    @new_pcp_subject = assigns( :pcp_subject )
    @new_pcp_step = @new_pcp_subject.pcp_steps.first
    assert_equal 1, @new_pcp_step.step_no

    # perform second release: commenting to presenting party

    assert @new_pcp_subject.user_is_owner_or_deputy?( @account_id, @new_pcp_step.acting_group_index )
    assert_equal 0, @new_pcp_step.release_type, @new_pcp_step.errors.messages
    assert_difference( 'PcpStep.count', 1 )do
      get :update_release, id: @new_pcp_subject
    end
    @new_pcp_subject = assigns( :pcp_subject )
    @new_pcp_step = @new_pcp_subject.pcp_steps.first
    assert_equal 2, @new_pcp_step.step_no

    # update for release to commenting party

    assert_no_difference([ 'PcpSubject.count', 'PcpStep.count' ])do
      patch :update, id: @new_pcp_subject, 
        pcp_subject: { 
        pcp_steps_attributes: {  '0' => { id: @new_pcp_step.id, report_version: 'C', subject_version: 'B' }}}
    end
    @new_pcp_subject = assigns( :pcp_subject )
    @new_pcp_step = @new_pcp_subject.pcp_steps.first
    assert_equal 2, @new_pcp_step.step_no

    # perform third release: presenting to commenting party

    assert_equal 0, @new_pcp_step.release_type, @new_pcp_step.errors.messages
    assert_difference( 'PcpStep.count', 1 )do
      get :update_release, id: @new_pcp_subject
    end
    @new_pcp_subject = assigns( :pcp_subject )
    @new_pcp_step = @new_pcp_subject.pcp_steps.first
    assert_equal 3, @new_pcp_step.step_no

    # update for approval to presenting party

    assert_no_difference([ 'PcpSubject.count', 'PcpStep.count' ])do
      patch :update, id: @new_pcp_subject, 
        pcp_subject: { 
        pcp_steps_attributes: {  '0' => { id: @new_pcp_step.id, report_version: 'D', new_assmt: final_assessment }}}
    end
    @new_pcp_subject = assigns( :pcp_subject )
    @new_pcp_step = @new_pcp_subject.pcp_steps.first
    assert_equal 3, @new_pcp_step.step_no

    # perform third release: presenting to commenting party

    assert_equal 1, @new_pcp_step.release_type, @new_pcp_step.errors.messages
    assert_difference( 'PcpStep.count', 0 )do
      get :update_release, id: @new_pcp_subject
    end
    @new_pcp_subject = assigns( :pcp_subject )
    @new_pcp_step = @new_pcp_subject.pcp_steps.first
    assert_equal 3, @new_pcp_step.step_no
    assert @new_pcp_step.status_closed?

  end

  end

end