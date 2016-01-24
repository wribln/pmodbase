require 'test_helper'
class DsrStatusRecordTest2 < ActiveSupport::TestCase

  test 'submission group' do     
    # must be existing submission group or nil
    dd = dsr_status_records( :dsr_rec_one )
    dd.submission_group_id = nil
    assert dd.valid?

    dd.submission_group_id = 0
    refute dd.valid?
    assert_includes dd.errors, :submission_group_id

    dd.errors.clear
    dd.submission_group_id = submission_groups( :sub_group_one ).id 
    assert dd.valid?

    SubmissionGroup.destroy( dd.submission_group_id )
    refute dd.valid?
    assert_includes dd.errors, :submission_group_id
  end

  [ :prep_activity_id, :subm_activity_id ].each do |pa|
    test "programe activity #{ pa }" do
      # must be existing programme activity or nil
      dd = dsr_status_records( :dsr_rec_one )
      dd.send( "#{pa}=", nil )
      assert dd.valid?
  
        dd.send( "#{pa}=", 0 )
        refute dd.valid?
        assert_includes dd.errors, pa
  
        dd.errors.clear
        dd.send( "#{pa}=", programme_activities( :ppa_one ).id )
        assert dd.valid?
  
        ProgrammeActivity.destroy( dd.send( pa ))
        dd.send :update_plan_dates
  
        refute dd.valid?
        assert_includes dd.errors, pa
    end
  end

  test 'programme activities must not be the same' do
    dd = dsr_status_records( :dsr_rec_two )
    dd.subm_activity_id = dd.prep_activity_id
    refute dd.valid?
    dd.prep_activity_id = programme_activities( :ppa_one )
    dd.subm_activity_id = programme_activities( :ppa_two )
    assert dd.valid?
  end

  test 'planned start of preparation' do
    p1 = programme_activities( :ppa_one )
    p2 = programme_activities( :ppa_two )
    dd = dsr_status_records( :dsr_rec_one )

    # check preconditions

    assert_nil dd.prep_activity_id
    assert_nil dd.plnd_prep_start
    assert_nil dd.estm_prep_start
    assert dd.valid?
    assert p1.valid?
    assert p2.valid?
    dd.send :update_plan_dates
    assert dd.valid?
    assert_nil dd.estm_prep_start

    # try programme activity

    dd.prep_activity_id = p1.id 
    assert dd.valid?
    dd.send :update_plan_dates
    assert_equal p1.start_date, dd.plnd_prep_start

    # update programme activity

    dd.prep_activity_id = p2.id
    assert dd.valid?
    dd.send :update_plan_dates
    assert_equal p2.start_date, dd.plnd_prep_start

    # try estimated prep start 

    dd.prep_activity_id = nil
    dd.estm_prep_start = '2015-02-15'.to_date
    assert dd.valid?
    dd.send :update_plan_dates
    assert_equal '2015-02-15'.to_date, dd.plnd_prep_start

    # update first_plan_date

    dd.estm_prep_start = '2016-03-16'.to_date
    assert dd.valid?
    dd.send :update_plan_dates
    assert_equal '2016-03-16'.to_date, dd.plnd_prep_start

    # an activity with an earlier plan date should not cause a change

    dd.prep_activity_id = p1.id
    assert p1.start_date < dd.estm_prep_start
    dd.send :update_plan_dates
    assert_equal dd.estm_prep_start, dd.plnd_prep_start

    # an activity with a later plan date will cause a change

    dd.prep_activity_id = p2.id
    assert p2.start_date > dd.estm_prep_start
    dd.send :update_plan_dates
    assert_equal p2.start_date, dd.plnd_prep_start

    # removing the activity should reverse to the estimated date

    dd.prep_activity_id = nil
    dd.send :update_plan_dates
    assert_equal dd.estm_prep_start, dd.plnd_prep_start

  end

  test 'planned start of submission' do
    p1 = programme_activities( :ppa_one )
    p2 = programme_activities( :ppa_two )
    dd = dsr_status_records( :dsr_rec_one )

    # check preconditions

    assert_nil dd.prep_activity_id
    assert_nil dd.plnd_submission_1
    assert_nil dd.estm_submission
    assert dd.valid?
    assert p1.valid?
    assert p2.valid?
    dd.send :update_plan_dates
    assert dd.valid?
    assert_nil dd.estm_submission

    # try programme activity

    dd.prep_activity_id = p1.id 
    assert dd.valid?
    dd.send :update_plan_dates
    assert_equal p1.finish_date, dd.plnd_submission_1

    # update programme activity

    dd.prep_activity_id = p2.id
    assert dd.valid?
    dd.send :update_plan_dates
    assert_equal p2.finish_date, dd.plnd_submission_1

    # try estimated prep start 

    dd.prep_activity_id = nil
    dd.estm_submission = '2015-02-15'.to_date
    assert dd.valid?
    dd.send :update_plan_dates
    assert_equal '2015-02-15'.to_date, dd.plnd_submission_1

    # update first_plan_date

    dd.estm_submission = '2016-03-16'.to_date
    assert dd.valid?
    dd.send :update_plan_dates
    assert_equal '2016-03-16'.to_date, dd.plnd_submission_1

    # an activity with an earlier plan date should not cause a change

    dd.prep_activity_id = p1.id
    assert p1.finish_date < dd.estm_submission
    dd.send :update_plan_dates
    assert_equal dd.estm_submission, dd.plnd_submission_1

    # an activity with a later plan date will cause a change

    dd.prep_activity_id = p2.id
    assert p2.finish_date > dd.estm_submission
    dd.send :update_plan_dates
    assert_equal p2.finish_date, dd.plnd_submission_1

    # removing the activity should reverse to the estimated date

    dd.prep_activity_id = nil
    dd.send :update_plan_dates
    assert_equal dd.estm_submission, dd.plnd_submission_1

  end

  test 'planned completion of document' do
    p1 = programme_activities( :ppa_one )
    p2 = programme_activities( :ppa_two )
    dd = dsr_status_records( :dsr_rec_one )

    # check preconditions

    assert_nil dd.subm_activity_id
    assert_nil dd.plnd_completion
    assert_nil dd.estm_completion
    assert dd.valid?
    assert p1.valid?
    assert p2.valid?
    dd.send :update_plan_dates
    assert dd.valid?
    assert_nil dd.estm_completion

    # try programme activity

    dd.subm_activity_id = p1.id 
    assert dd.valid?
    dd.send :update_plan_dates
    assert_equal p1.finish_date, dd.plnd_completion

    # update programme activity

    dd.subm_activity_id = p2.id
    assert dd.valid?
    dd.send :update_plan_dates
    assert_equal p2.finish_date, dd.plnd_completion

    # try estimated prep start 

    dd.subm_activity_id = nil
    dd.estm_completion = '2015-02-15'.to_date
    assert dd.valid?
    dd.send :update_plan_dates
    assert_equal '2015-02-15'.to_date, dd.plnd_completion

    # update first_plan_date

    dd.estm_completion = '2016-03-16'.to_date
    assert dd.valid?
    dd.send :update_plan_dates
    assert_equal '2016-03-16'.to_date, dd.plnd_completion

    # an activity with an earlier plan date should not cause a change

    dd.subm_activity_id = p1.id
    assert p1.finish_date < dd.estm_completion
    dd.send :update_plan_dates
    assert_equal dd.estm_completion, dd.plnd_completion

    # an activity with a later plan date will cause a change

    dd.subm_activity_id = p2.id
    assert p2.finish_date > dd.estm_completion
    dd.send :update_plan_dates
    assert_equal p2.finish_date, dd.plnd_completion

    # removing the activity should reverse to the estimated date

    dd.subm_activity_id = nil
    dd.send :update_plan_dates
    assert_equal dd.estm_completion, dd.plnd_completion

  end

  test 'setting defaults' do
    dd = dsr_status_records( :dsr_rec_one )
    dd.quantity = nil
    dd.weight = nil
    dd.send :set_defaults
    assert_equal 1, dd.quantity
    assert_equal 1.0, dd.weight

    dd.quantity = 0
    dd.weight = 0.0
    dd.send :set_defaults
    assert_equal 0, dd.quantity
    assert_equal 0.0, dd.weight
  end

  test 'ready for prepare' do
    dd = dsr_status_records( :dsr_rec_two )
    dd.check_prepare_readiness
    assert dd.errors.empty?

    # weight must be >= 0
    dd.weight = nil
    dd.check_prepare_readiness
    assert_includes dd.errors, :weight

    dd.errors.clear
    dd.weight = -1.0
    dd.check_prepare_readiness
    assert_includes dd.errors, :weight

    dd.weight = 1.0
    assert dd.valid?

    # quantitiy must be '1'
    dd.quantity = nil
    dd.check_prepare_readiness
    assert_includes dd.errors, :quantity

    dd.errors.clear
    dd.quantity = 0
    dd.check_prepare_readiness
    assert_includes dd.errors, :quantity

    dd.errors.clear
    dd.quantity = 2
    dd.check_prepare_readiness
    assert_includes dd.errors, :quantity

    dd.errors.clear
    dd.quantity = 1
    dd.check_prepare_readiness
    assert dd.valid?

    # submission frequency must be 'single'-type

    dd.sub_frequency = 0
    assert dd.single_submission_frequency?
    dd.check_prepare_readiness
    assert dd.valid?

    dd.sub_frequency = 1
    assert dd.single_submission_frequency?
    dd.check_prepare_readiness
    assert dd.valid?

    dd.sub_frequency = 2
    assert_not dd.single_submission_frequency?
    dd.check_prepare_readiness
    assert_includes dd.errors, :sub_frequency

    dd.sub_frequency = 3 # invalid
    assert_not dd.single_submission_frequency?
    dd.check_prepare_readiness
    assert_includes dd.errors, :sub_frequency

  end

  test 'ready for submission' do
    dd = dsr_status_records( :dsr_rec_two )
    dd.check_submit_readiness
    assert dd.errors.empty?

    # submission purpose must be A or I
    dd.sub_purpose = 0
    assert dd.submission_required?
    dd.check_submit_readiness
    assert dd.errors.empty?

    dd.sub_purpose = 1
    assert dd.submission_required?
    dd.check_submit_readiness
    assert dd.errors.empty?

    dd.sub_purpose = 2
    assert_not dd.submission_required?
    dd.check_submit_readiness
    assert_includes dd.errors, :sub_purpose

    dd.errors.clear
    dd.sub_purpose = 3
    assert_not dd.submission_required?
    dd.check_submit_readiness
    assert_includes dd.errors, :sub_purpose

    dd.errors.clear
    dd.sub_purpose = -1
    assert_not dd.submission_required?
    dd.check_submit_readiness
    assert_includes dd.errors, :sub_purpose
  end

  test 'ready to withdraw' do
    dd = dsr_status_records( :dsr_rec_two )
    dd.weight = 0.0
    dd.quantity = 0
    dd.check_withdraw_readiness
    assert dd.errors.empty?

    # weight must be '0.0'
    dd.weight = nil
    dd.check_withdraw_readiness
    assert_includes dd.errors, :weight

    dd.errors.clear
    dd.weight = -1.0
    dd.check_withdraw_readiness
    assert_includes dd.errors, :weight

    dd.errors.clear
    dd.weight = 1.0
    dd.check_withdraw_readiness
    assert_includes dd.errors, :weight

    dd.errors.clear
    dd.weight = 0.0
    dd.check_withdraw_readiness
    assert dd.errors.empty?

    # quantitiy must be '0'
    dd.quantity = nil
    dd.check_withdraw_readiness
    assert_includes dd.errors, :quantity

    dd.errors.clear
    dd.quantity = -1
    dd.check_withdraw_readiness
    assert_includes dd.errors, :quantity

    dd.errors.clear
    dd.quantity = 1
    dd.check_withdraw_readiness
    assert_includes dd.errors, :quantity

    dd.errors.clear
    dd.quantity = 0
    dd.check_withdraw_readiness
    assert dd.valid?

  end

end
