require 'test_helper'
class PcpStepTest < ActiveSupport::TestCase

  test 'fixture 1' do
    ps = pcp_steps( :one )
    assert ps.valid?, ps.errors.messages
    assert_equal ps.pcp_subject_id, pcp_subjects( :one ).id
    assert_equal 0, ps.step_no
    refute_empty ps.subject_version
    assert_equal 0, ps.subject_status
    assert_equal 0, ps.prev_assmt
    assert_nil ps.new_assmt
    assert_nil ps.subject_date
    assert_nil ps.note
    assert_nil ps.due_date
    assert_nil ps.released_by
    assert_nil ps.released_at
    assert_nil ps.subject_title
    assert_nil ps.project_doc_id
  end

  test 'fixture 2' do
    ps = pcp_steps( :two )
    assert ps.valid?, ps.errors.messages
    assert_equal ps.pcp_subject_id, pcp_subjects( :one ).id
    assert_equal 1, ps.step_no
    refute_empty ps.subject_version
    assert_equal 1, ps.subject_status
    assert_equal 0, ps.prev_assmt
    assert_nil ps.subject_date
    assert_nil ps.note
    assert_nil ps.new_assmt
    refute_nil ps.due_date
    refute_nil ps.released_by
    refute_nil ps.released_at
    assert_nil ps.subject_title
    assert_nil ps.project_doc_id
  end

  test 'step labels / acting_group_switch' do
    ps = pcp_steps( :one )
    assert_equal PcpStep::STEP_LABELS[ 0 ], ps.step_label, 'Initial Release'
    assert_equal 0, ps.acting_group_switch, '0 - originator'
    ps.step_no += 1
    assert_equal PcpStep::STEP_LABELS[ 1 ], ps.step_label, 'Initial Review'
    assert_equal 1, ps.acting_group_switch, '1 - reviewing party'
    ps.step_no += 1
    assert_equal PcpStep::STEP_LABELS[ 2 ], ps.step_label, 'First Response'
    assert_equal 0, ps.acting_group_switch, '0 - responding party'
    ps.step_no += 1
    assert_equal PcpStep::STEP_LABELS[ 3 ], ps.step_label, 'Second Review'
    assert_equal 1, ps.acting_group_switch, '1 - reviewing party'
    ps.step_no += 1
    assert_equal PcpStep::STEP_LABELS[ 4 ], ps.step_label, 'Second Response'
    assert_equal 0, ps.acting_group_switch, '0 - responding party'
    ps.step_no += 1
    assert_equal 'Review No 3', ps.step_label
    assert_equal 1, ps.acting_group_switch, '1 - reviewing party'
    ps.step_no += 1
    assert_equal 'Response No 3', ps.step_label
    assert_equal 0, ps.acting_group_switch, '0 - responding party'
    ps.step_no += 1
    assert_equal 'Review No 4', ps.step_label
    assert_equal 1, ps.acting_group_switch, '1 - reviewing party'
  end

  test 'related pcp subject must exist' do
    ps = pcp_steps( :one )
    ps.pcp_subject_id = nil 
    refute ps.valid?
    assert_includes ps.errors, :pcp_subject_id
  end

  test 'prev/new assessment not possible in step 0' do
    ps = pcp_steps( :one )
    ps.prev_assmt = nil

    (1..4).each do |i|
      ps.new_assmt = i
      refute ps.valid?
      assert_includes ps.errors, :prev_assmt
    end
  end

  test 'prev/new assignment range' do
    ps = pcp_steps( :one )

    ps.prev_assmt = -1
    ps.new_assmt = -1
    refute ps.valid?
    assert_includes ps.errors, :prev_assmt
    assert_includes ps.errors, :new_assmt

    ps.prev_assmt = 5
    ps.new_assmt = 5
    refute ps.valid?
    assert_includes ps.errors, :prev_assmt
    assert_includes ps.errors, :new_assmt
  end

  test 'current overall assessment - new assessment prevails unless nil' do
    ps = pcp_steps( :one )

    ps.prev_assmt = nil
    ps.new_assmt = nil
    assert_equal ps.current_assmt, nil

    (0..4).each do |pa|
      ps.prev_assmt = pa
      assert_equal ps.current_assmt, pa
    end

    (0..4).each do |pa|
      ps.prev_assmt = pa
      (0..4).each do |na|
        ps.new_assmt = na
        assert_equal ps.current_assmt, na
      end
    end
  end

  test 'assessment codes and labels' do
    ps = PcpStep.new
    assert_equal PcpStep::ASSESSMENT_CODES[ 0 ], PcpStep.assessment_code( nil )
    assert_equal PcpStep::ASSESSMENT_LABELS[ 0 ], PcpStep.assessment_label( nil )

    assert_equal PcpStep::ASSESSMENT_CODES[ 0 ], PcpStep.assessment_code( 0 )
    assert_equal PcpStep::ASSESSMENT_LABELS[ 0 ], PcpStep.assessment_label( 0 )

    assert_equal PcpStep::ASSESSMENT_CODES[ 1 ], PcpStep.assessment_code( 1 )
    assert_equal PcpStep::ASSESSMENT_LABELS[ 1 ], PcpStep.assessment_label( 1 )

    assert_equal PcpStep::ASSESSMENT_CODES[ 2 ], PcpStep.assessment_code( 2 )
    assert_equal PcpStep::ASSESSMENT_LABELS[ 2 ], PcpStep.assessment_label( 2 )

    assert_equal PcpStep::ASSESSMENT_CODES[ 3], PcpStep.assessment_code( 3 )
    assert_equal PcpStep::ASSESSMENT_LABELS[ 3 ], PcpStep.assessment_label( 3 )

    assert_equal PcpStep::ASSESSMENT_CODES[ 4 ], PcpStep.assessment_code( 4 )
    assert_equal PcpStep::ASSESSMENT_LABELS[ 4 ], PcpStep.assessment_label( 4 )
  end

  test 'subject status for step 0' do
    ps = PcpStep.new
    ps.step_no = 0
    ps.new_assmt = nil

    (0..4).each do |pa|
      ps.prev_assmt = pa
      ps.subject_status = ps.new_subject_status
      refute ps.status_closed?
      assert_equal 0, ps.subject_status
    end

    ps.prev_assmt = 0
    (0..4).each do |na|
      ps.new_assmt = na
      ps.subject_status = ps.new_subject_status
      refute ps.status_closed?
      assert_equal 0, ps.subject_status
    end
  end

  test 'subject status for step 1' do
    ps = PcpStep.new
    ps.step_no = 1

    # now at step 1 - try to close subject

    ps.prev_assmt = 0
    ps.subject_status = ps.new_subject_status
    refute ps.status_closed?

    ps.new_assmt = 0
    ps.subject_status = ps.new_subject_status
    refute ps.status_closed?

    ps.new_assmt = 1
    ps.subject_status = ps.new_subject_status
    assert ps.status_closed?

    ps.new_assmt = 2
    ps.subject_status = ps.new_subject_status
    refute ps.status_closed?

    ps.new_assmt = 3
    ps.subject_status = ps.new_subject_status
    refute ps.status_closed?

    ps.new_assmt = 4
    ps.subject_status = ps.new_subject_status
    assert ps.status_closed?

  end

  test 'acting_group_switch and related methods' do
    ps = PcpStep.new

    ps.step_no = 0
    assert_equal 0, ps.acting_group_switch
    assert ps.in_presenting_group?
    refute ps.in_commenting_group?

    ps.step_no = 1
    assert_equal 1, ps.acting_group_switch
    refute ps.in_presenting_group?
    assert ps.in_commenting_group?

    ps.step_no = 2
    assert_equal 0, ps.acting_group_switch
    assert ps.in_presenting_group?
    refute ps.in_commenting_group?

    ps.step_no = 3
    assert_equal 1, ps.acting_group_switch
    refute ps.in_presenting_group?
    assert ps.in_commenting_group?

  end

end
