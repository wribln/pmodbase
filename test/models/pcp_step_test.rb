require 'test_helper'
class PcpStepTest < ActiveSupport::TestCase

  test 'fixture 1' do
    ps = pcp_steps( :one )
    assert ps.valid?, ps.errors.messages
    assert_equal ps.pcp_subject_id, pcp_subjects( :one ).id
    assert_equal 0, ps.step_no
    refute_empty ps.subject_version
    assert_equal 0, ps.subject_status
    assert_equal 0, ps.assessment
    assert_nil ps.subject_date
    assert_nil ps.note
    assert_nil ps.due_date
  end

  test 'fixture 2' do
    ps = pcp_steps( :two )
    assert ps.valid?, ps.errors.messages
    assert_equal ps.pcp_subject_id, pcp_subjects( :one ).id
    assert_equal 1, ps.step_no
    refute_empty ps.subject_version
    assert_equal 0, ps.subject_status
    assert_equal 0, ps.assessment
    assert_nil ps.subject_date
    assert_nil ps.note
    refute_nil ps.due_date
  end

  test 'step labels / ballpark' do
    ps = pcp_steps( :one )
    assert_equal PcpStep::STEP_LABELS[ 0 ], ps.step_label
    assert_equal 0, ps.ballpark, '0 - originator'
    ps.step_no += 1
    assert_equal PcpStep::STEP_LABELS[ 1 ], ps.step_label
    assert_equal 1, ps.ballpark, '1 - reviewing party'
    ps.step_no += 1
    assert_equal PcpStep::STEP_LABELS[ 2 ], ps.step_label
    assert_equal 0, ps.ballpark, '0 - responding party'
    ps.step_no += 1
    assert_equal PcpStep::STEP_LABELS[ 3 ], ps.step_label
    assert_equal 1, ps.ballpark, '1 - reviewing party'
    ps.step_no += 1
    assert_equal '2nd Review', ps.step_label
    assert_equal 0, ps.ballpark, '0 - responding party'
    ps.step_no += 1
    assert_equal '2nd Response', ps.step_label
    ps.step_no += 1
    assert_equal '3rd Review', ps.step_label
    ps.step_no += 1
    assert_equal '3rd Response', ps.step_label
  end

  test 'related pcp subject must exist' do
    ps = pcp_steps( :one )
    ps.pcp_subject_id = nil 
    refute ps.valid?
    assert_includes ps.errors, :pcp_subject_id
  end

  test 'assessment codes and labels' do
    ps = PcpStep.new
    ps.assessment = 0
  end

end
