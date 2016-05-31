require 'test_helper'
class DsrStatusRecord1Test < ActiveSupport::TestCase

  test 'fixture usefulness 1 - minimum content' do
    dd = dsr_status_records( :dsr_rec_one )
    refute dd.title.nil?
    assert dd.title.length <= MAX_LENGTH_OF_TITLE
    assert_equal 0, dd.document_status
    assert_equal 0, dd.document_status_b
    assert_nil dd.project_doc_id
    assert_nil dd.sender_doc_id
    assert_equal groups( :group_one ).id, dd.sender_group_id
    assert_equal dd.sender_group_id, dd.sender_group_b_id
    assert_nil dd.receiver_group_id
    assert_nil dd.receiver_doc_id
    assert_equal 0, dd.sub_purpose
    assert_equal 0, dd.sub_frequency
    assert_equal 1, dd.quantity
    assert_equal 0, dd.quantity_b
    assert_equal 1.0, dd.weight
    assert_equal 0.0, dd.weight_b
    assert_nil dd.dsr_doc_group_id
    assert_nil dd.submission_group_id
    assert_nil dd.submission_group_b_id
    assert_nil dd.prep_activity_id
    assert_nil dd.subm_activity_id
    assert_nil dd.plnd_prep_start
    assert_nil dd.plnd_prep_start_b
    assert_nil dd.estm_prep_start
    assert_nil dd.actl_prep_start
    assert_nil dd.plnd_submission_1
    assert_nil dd.plnd_submission_b
    assert_nil dd.estm_submission
    assert_nil dd.actl_submission_1
    assert_nil dd.next_submission
    assert_nil dd.plnd_completion
    assert_nil dd.plnd_completion_b
    assert_nil dd.estm_completion
    assert_nil dd.actl_completion
    assert_nil dd.baseline_date
    assert_nil dd.notes
    assert_equal 0, dd.current_status
    assert_equal 0, dd.current_status_b
    assert_equal 0, dd.current_task
    assert_equal 0, dd.current_task_b
    assert dd.valid?
  end

  test 'fixture usefulness 2 - full content' do
    dd = dsr_status_records( :dsr_rec_two )
    refute dd.title.nil?
    assert dd.title.length <= MAX_LENGTH_OF_TITLE
    assert_equal 1, dd.document_status
    refute dd.project_doc_id.nil?
    assert dd.project_doc_id.length <= ProjectDocLog::MAX_LENGTH_OF_DOC_ID
    assert groups( :group_one ).id, dd.sender_group_id
    assert groups( :group_two ).id, dd.receiver_group_id
    refute dd.project_doc_id.nil?
    assert dd.project_doc_id.length <= ProjectDocLog::MAX_LENGTH_OF_DOC_ID
    refute dd.sender_doc_id.nil?
    assert dd.sender_doc_id.length <= MAX_LENGTH_OF_DOC_ID
    refute dd.receiver_doc_id.nil?
    assert dd.receiver_doc_id.length <= MAX_LENGTH_OF_DOC_ID
    assert_equal 1, dd.sub_purpose
    assert_equal 1, dd.sub_frequency
    assert_equal 0.01, dd.weight
    assert_equal 1, dd.quantity
    assert_equal dsr_doc_groups( :dsr_group_one ).id, dd.dsr_doc_group_id
    assert_equal dd.submission_group_id, dd.submission_group_b_id
    assert_equal submission_groups( :sub_group_one ).id, dd.submission_group_id
    assert_equal programme_activities( :ppa_one ).id, dd.prep_activity_id
    assert_equal programme_activities( :ppa_two ).id, dd.subm_activity_id
    assert_equal dsr_submissions( :dsr_sub_two ).id, dd.dsr_current_submission_id
    assert_equal Date.new( 2015, 5, 26 ), dd.plnd_prep_start
    assert_nil dd.plnd_prep_start_b
    assert_nil dd.estm_prep_start
    assert_nil dd.actl_prep_start
    assert_equal Date.new( 2015, 7, 30 ), dd.plnd_submission_1
    assert_nil dd.plnd_submission_b
    assert_nil dd.estm_submission
    assert_nil dd.actl_submission_1
    assert_nil dd.next_submission
    assert_equal Date.new( 2015, 8, 15 ), dd.plnd_completion
    assert_nil dd.plnd_completion_b
    assert_nil dd.estm_completion
    assert_nil dd.actl_completion
    assert_nil dd.baseline_date
    refute_nil dd.notes
    assert dd.notes.length <= MAX_LENGTH_OF_NOTE
    assert_equal 1, dd.current_status
    assert_equal 1, dd.current_task
    assert dd.valid?
  end

  test 'default values' do
    dd = DsrStatusRecord.new
    assert dd.title.nil?
    assert_equal 0,dd.document_status
    assert_nil dd.project_doc_id
    assert_nil dd.sender_doc_id
    assert_nil dd.receiver_doc_id
    assert_nil dd.sender_group_id
    assert_nil dd.receiver_group_id
    assert_equal 0, dd.sub_purpose
    assert_equal 0, dd.sub_frequency
    assert_equal 1, dd.quantity
    assert_equal 1.0, dd.weight
    assert_nil dd.dsr_doc_group_id
    assert_nil dd.submission_group_id
    assert_nil dd.prep_activity_id
    assert_nil dd.subm_activity_id
    assert_nil dd.dsr_current_submission_id
    assert_nil dd.notes
    assert_equal 0, dd.current_status
    assert_equal 0, dd.current_task
    assert dd.invalid?
    assert_includes dd.errors, :title
    assert_includes dd.errors, :sender_group_id
  end

  test 'validity checks - title' do
    dd = dsr_status_records( :dsr_rec_one )

    dd.title = nil
    assert dd.invalid?, 'title must not be nil'
    assert_includes dd.errors, :title

    dd.title = ''
    assert dd.invalid?, 'title must not be empty'
    assert_includes dd.errors, :title

    dd.title = '     '
    assert dd.invalid?, 'title must not be empty'
    assert_includes dd.errors, :title

    dd.title = ' a b  c '
    assert dd.valid?
    assert_equal 'a b c', dd.title
  end

  test 'validity checks - sender doc id' do
    dd = dsr_status_records( :dsr_rec_one )
    assert_nil dd.sender_doc_id
    dd.sender_doc_id = ' a b  c '
    assert dd.valid?
    assert_equal 'a b c', dd.sender_doc_id
  end

  test 'validity checks - receiver doc id' do
    dd = dsr_status_records( :dsr_rec_one )
    assert_nil dd.receiver_doc_id
    dd.receiver_doc_id = ' a b  c '
    assert dd.valid?
    assert_equal 'a b c', dd.receiver_doc_id
  end

  test 'validity checks - project doc id' do
    dd = dsr_status_records( :dsr_rec_one )
    assert_nil dd.project_doc_id
    dd.project_doc_id = ' a b  c '
    assert dd.valid?
    assert_equal 'a b c', dd.project_doc_id
  end

  test 'validity checks - sender group' do
    dd = dsr_status_records( :dsr_rec_one )

    dd.sender_group_id = nil
    assert dd.invalid?, 'sender_group_id must not be nil'
    assert_includes dd.errors, :sender_group_id

    dd.sender_group_id = 0
    assert dd.invalid?, 'sender_group_id must exist'
    assert_includes dd.errors, :sender_group_id
  end

  test 'label for sub_purpose' do # used in help texts
    assert_equal 'A - for Approval', DsrStatusRecord::DSR_SUB_PURPOSE_LABELS[0]
    assert_equal 'I - for Information', DsrStatusRecord::DSR_SUB_PURPOSE_LABELS[1]
    assert_equal 'N - no Submission', DsrStatusRecord::DSR_SUB_PURPOSE_LABELS[2]
  end

  test 'submission required and submission purpose range' do 
    dd = DsrStatusRecord.new
    dd.sub_purpose = -1
    refute dd.submission_required?
    assert dd.invalid?
    assert_includes dd.errors, :sub_purpose

    dd.sub_purpose = 0
    assert dd.submission_required?
    dd.valid?
    refute_includes dd.errors, :sub_purpose

    dd.sub_purpose = 1
    assert dd.submission_required?
    dd.valid?
    refute_includes dd.errors, :sub_purpose

    dd.sub_purpose = 2
    refute dd.submission_required?
    dd.valid?
    refute_includes dd.errors, :sub_purpose

    dd.sub_purpose = 3
    refute dd.submission_required?
    assert dd.invalid?
    assert_includes dd.errors, :sub_purpose
  end

  test 'single submission frequency and submission frequency range' do 
    dd = DsrStatusRecord.new
    dd.sub_frequency = -1
    refute dd.single_submission_frequency?
    assert dd.invalid?
    assert_includes dd.errors, :sub_frequency

    dd.sub_frequency = 0
    assert dd.single_submission_frequency?
    dd.valid?
    refute_includes dd.errors, :sub_frequency

    dd.sub_frequency = 1
    assert dd.single_submission_frequency?
    dd.valid?
    refute_includes dd.errors, :sub_frequency

    for i in (2..( DsrStatusRecord::DSR_SUB_FREQUENCY_LABELS.size - 1 ))
      dd.sub_frequency = i
      refute dd.single_submission_frequency?
      dd.valid?
      refute_includes dd.errors, :sub_frequency
    end

    dd.sub_frequency = DsrStatusRecord::DSR_SUB_FREQUENCY_LABELS.size
    refute dd.single_submission_frequency?
    assert dd.invalid?
    assert_includes dd.errors, :sub_frequency
  end

  test 'quantity and frequency combination' do 
    dd = dsr_status_records( :dsr_rec_one )
 
    dd.quantity = -1
    dd.sub_frequency = 0
    dd.valid?
    assert_includes dd.errors, :quantity

    dd.quantity = 0
    assert dd.valid?

    dd.quantity = 1
    assert dd.valid?

    dd.sub_frequency = 1
    assert dd.valid?

    for i in (2..( DsrStatusRecord::DSR_SUB_FREQUENCY_LABELS.size - 1 ))
      dd.sub_frequency = i
      assert dd.invalid?
      assert_includes dd.errors, :base
    end

    dd.quantity = 2
    for i in (0..( DsrStatusRecord::DSR_SUB_FREQUENCY_LABELS.size - 1 ))
      dd.sub_frequency = i
      assert dd.valid?
    end

  end

  test 'document group handling' do
    # good case
    dd = dsr_status_records( :dsr_rec_one )
    dd.dsr_doc_group_id = dsr_doc_groups( :dsr_group_one ).id
    dd.valid?
    assert dd.valid?

    # bad case
    dd.dsr_doc_group_id = 0
    assert dd.invalid?
    assert_includes dd.errors, :dsr_doc_group_id

    # make it good again
    dd.dsr_doc_group_id = nil
    assert dd.valid?

    # groups in both dsr_status_record and dsr_doc_group must match!
    dg = dsr_doc_groups( :dsr_group_two )
    dd.dsr_doc_group_id = dg.id
    assert_not_equal dd.sender_group_id, dg.group_id
    assert dd.invalid?
    assert_includes dd.errors, :dsr_doc_group_id

    # make it good again
    dd.sender_group_id = dg.group_id
    assert dd.valid?
    
  end

  test 'all scopes' do 
    as = DsrStatusRecord.ff_id( dsr_status_records( :dsr_rec_one ).id )
    assert_equal 1, as.length

    as = DsrStatusRecord.ff_id( 0 )
    assert_equal 0, as.length

    as = DsrStatusRecord.ff_group( groups( :group_one ))
    assert_equal 2, as.length

    as = DsrStatusRecord.ff_group( 0 )
    assert_equal 0, as.length

    as = DsrStatusRecord.ff_title( 'document' )
    assert_equal 2, as.length

    as = DsrStatusRecord.ff_title( 'foobar' )
    assert_equal 0, as.length

    as = DsrStatusRecord.ff_docgr( dsr_doc_groups( :dsr_group_one ).id )
    assert_equal 1, as.length

    as = DsrStatusRecord.ff_docgr( 0 )
    assert_equal 0, as.length

    as = DsrStatusRecord.ff_subgr( submission_groups( :sub_group_one ).id )
    assert_equal 1, as.length

    as = DsrStatusRecord.ff_subgr( 0 )
    assert_equal 0, as.length

    as = DsrStatusRecord.ff_docsts( 1 )
    assert_equal 1, as.length

    as = DsrStatusRecord.ff_docsts( 0 )
    assert_equal 1, as.length

    as = DsrStatusRecord.ff_docsts( 1 )
    assert_equal 1, as.length

    as = DsrStatusRecord.ff_docsts( 2 )
    assert_equal 0, as.length

    as = DsrStatusRecord.ff_wflsts( 0 )
    assert_equal 1, as.length

    as = DsrStatusRecord.ff_wflsts( 1 )
    assert_equal 1, as.length

    as = DsrStatusRecord.ff_wflsts( 2 )
    assert_equal 0, as.length

  end

end
