require 'test_helper'
class DsrStatusRecordTest1 < ActiveSupport::TestCase

  test 'upon destroy all related submissions will be deleted' do 
    d = dsr_status_records( :dsr_rec_two )
    n = DsrSubmission.count
    assert_equal 2, DsrSubmission.where( dsr_status_record_id: d.id ).count
    d.destroy 
    assert_equal 0, DsrSubmission.where( dsr_status_record_id: d.id ).count
    assert_equal n-2, DsrSubmission.count
  end

  test 'determine late prep status' do
    d =  DsrStatusRecord.new
    d.plnd_prep_start = nil
    d.actl_prep_start = nil
    assert_equal 0, d.determine_late_prep
    d.plnd_prep_start = Date.today - 2
    assert_equal 1, d.determine_late_prep # too late
    d.plnd_prep_start += 7
    assert_equal 5, d.determine_late_prep # quite late
    d.plnd_prep_start += 7
    assert_equal 2, d.determine_late_prep # not quite or too late
    d.actl_prep_start = d.plnd_prep_start
    assert_equal 4, d.determine_late_prep # just in time
    d.actl_prep_start += 1
    assert_equal 3, d.determine_late_prep # was late
  end

  test 'determine late submission status' do
    d =  DsrStatusRecord.new
    d.plnd_submission_1 = nil
    d.actl_submission_1 = nil
    assert_equal 0, d.determine_late_subm
    d.plnd_submission_1 = Date.today - 2
    assert_equal 1, d.determine_late_subm
    d.plnd_submission_1 += 7
    assert_equal 5, d.determine_late_subm
    d.plnd_submission_1 += 7
    assert_equal 2, d.determine_late_subm
    d.actl_submission_1 = d.plnd_submission_1
    assert_equal 4, d.determine_late_subm
    d.actl_submission_1 += 1
    assert_equal 3, d.determine_late_subm
  end

  test 'determine late completion status' do
    d =  DsrStatusRecord.new
    d.plnd_completion = nil
    d.actl_completion = nil
    assert_equal 0, d.determine_late_compl
    d.plnd_completion = Date.today - 2
    assert_equal 1, d.determine_late_compl
    d.plnd_completion += 7
    assert_equal 5, d.determine_late_compl
    d.plnd_completion += 7
    assert_equal 2, d.determine_late_compl
    d.actl_completion = d.plnd_completion
    assert_equal 4, d.determine_late_compl
    d.actl_completion += 1
    assert_equal 3, d.determine_late_compl
  end

end
