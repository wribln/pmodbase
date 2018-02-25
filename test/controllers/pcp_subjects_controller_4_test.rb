require 'test_helper'
class PcpSubjectsController4Test < ActionDispatch::IntegrationTest

  # make sure only the commenting party can change the assessment

  setup do 
    @pcp_subject = pcp_subjects( :two )
    @pcp_step = @pcp_subject.current_step
    signon_by_user accounts( :one )
    assert @pcp_subject.pcp_members.destroy_all
  end

  test 'pre-conditions' do
    assert_equal 0, @pcp_step.step_no
    assert @pcp_step.in_presenting_group?
  end

  test 'try to change assessment' do

    get edit_pcp_subject_path( id: @pcp_subject )
    assert_response :success

    assert_nil @pcp_step.new_assmt
    assert_equal 'A', @pcp_step.report_version
    patch pcp_subject_path( id: @pcp_subject, params: { pcp_subject: { pcp_steps_attributes: {  '0' => { id: @pcp_step.id, report_version: 'B', new_assmt: '2' }}}})
    @pcp_subject = assigns( :pcp_subject )
    refute_nil @pcp_subject
    assert_redirected_to @pcp_subject
    @pcp_subject.reload
    @pcp_step.reload
    assert_nil @pcp_step.new_assmt
    assert_equal 'B', @pcp_step.report_version

    # release subject and try again
    # note: pcp_step is still at step_no == 0

    assert_difference( 'PcpStep.count' )do
      get pcp_subject_release_path( id: @pcp_subject )
    end
    assert_redirected_to pcp_release_doc_path( @pcp_subject, @pcp_step.step_no )

    assert_nil @pcp_step.new_assmt
    assert_equal 'B', @pcp_step.report_version

    patch pcp_subject_path( id: @pcp_subject, params:{ pcp_subject: { pcp_steps_attributes: {  '0' => { id: @pcp_step.id, report_version: 'C', new_assmt: '2' }}}})
    assert_response :forbidden

    @pcp_subject = assigns( :pcp_subject )
    refute_nil @pcp_subject
    refute_nil assigns( :pcp_curr_step )
    refute_nil assigns( :pcp_prev_step )
    assert_equal 1, assigns( :pcp_viewing_group_map )

    @pcp_subject.reload
    @pcp_step.reload
    assert_nil @pcp_step.new_assmt
    assert_equal 'B', @pcp_step.report_version

    # try new step

    @pcp_step = assigns( :pcp_curr_step )
    patch pcp_subject_path( id: @pcp_subject, params:{ pcp_subject: { pcp_steps_attributes: { '0' => { id: @pcp_step.id, report_version: 'D', new_assmt: '2' }}}})
    assert_response :forbidden

    @pcp_subject = assigns( :pcp_subject )
    refute_nil @pcp_subject
    refute_nil assigns( :pcp_curr_step )
    refute_nil assigns( :pcp_prev_step )
    assert_equal 1, assigns( :pcp_viewing_group_map )

    @pcp_subject.reload
    @pcp_step.reload
    assert_nil @pcp_step.new_assmt
    assert_nil @pcp_step.report_version

  end

end
