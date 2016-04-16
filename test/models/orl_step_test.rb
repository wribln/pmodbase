require 'test_helper'
class OrlStepTest < ActiveSupport::TestCase

  test 'fixture 1' do
    os = orl_steps( :one )
    assert os.valid?, os.errors.messages
    assert_equal os.orl_subject_id, orl_subjects( :one ).id
    assert_equal 0, os.step_no
    refute_empty os.subject_version
    assert_equal 0, os.subject_status
    assert_equal 0, os.assessment
    assert_nil os.subject_date
    assert_nil os.note
    assert_nil os.due_date
  end

  test 'fixture 2' do
    os = orl_steps( :two )
    assert os.valid?, os.errors.messages
    assert_equal os.orl_subject_id, orl_subjects( :one ).id
    assert_equal 1, os.step_no
    refute_empty os.subject_version
    assert_equal 0, os.subject_status
    assert_equal 0, os.assessment
    assert_nil os.subject_date
    assert_nil os.note
    refute_nil os.due_date
  end

  test 'step labels / ballpark' do
    os = orl_steps( :one )
    assert_equal OrlStep::STEP_LABELS[ 0 ], os.step_label
    assert_equal 0, os.ballpark, '0 - originator'
    os.step_no += 1
    assert_equal OrlStep::STEP_LABELS[ 1 ], os.step_label
    assert_equal 1, os.ballpark, '1 - reviewing party'
    os.step_no += 1
    assert_equal OrlStep::STEP_LABELS[ 2 ], os.step_label
    assert_equal 0, os.ballpark, '0 - responding party'
    os.step_no += 1
    assert_equal OrlStep::STEP_LABELS[ 3 ], os.step_label
    assert_equal 1, os.ballpark, '1 - reviewing party'
    os.step_no += 1
    assert_equal '2nd Review', os.step_label
    assert_equal 0, os.ballpark, '0 - responding party'
    os.step_no += 1
    assert_equal '2nd Response', os.step_label
    os.step_no += 1
    assert_equal '3rd Review', os.step_label
    os.step_no += 1
    assert_equal '3rd Response', os.step_label
  end

  test 'related orl subject must exist' do
    os = orl_steps( :one )
    os.orl_subject_id = nil 
    refute os.valid?
    assert_includes os.errors, :orl_subject_id
  end

  test 'assessment codes and labels' do
    os = OrlStep.new
    os.assessment = 0
  end

end
