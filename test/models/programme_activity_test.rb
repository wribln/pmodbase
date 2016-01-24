require 'test_helper'

class ProgrammeActivityTest < ActiveSupport::TestCase

  test 'usefulness of fixture' do
    pa = programme_activities( :ppa_one )
    assert_not_nil pa.project_id
    assert_not_nil pa.activity_id
    assert_not_nil pa.start_date
    assert_not_nil pa.finish_date
    assert pa.start_date.kind_of? Date 
    assert pa.finish_date.kind_of? Date
    assert pa.start_date <= pa.finish_date
    assert pa.valid?
  end

  test 'default values' do
    pa = ProgrammeActivity.new
    assert_nil pa.project_id
    assert_nil pa.activity_id
    assert_nil pa.start_date
    assert_nil pa.finish_date
  end

  test 'required fields' do
    pa = ProgrammeActivity.new
    assert_not pa.valid?
    assert_includes pa.errors, :base
    # set start_date, validation set finish date
    pa.start_date = '2.2.2020'
    assert pa.valid?
    # clear start_date, validation resets it from finish date
    pa.start_date = nil 
    assert pa.valid?
    assert_equal pa.start_date, Date.new( 2020, 2, 2 )
    # clear both
    pa.start_date = nil
    pa.finish_date = nil
    assert_not pa.valid?
  end

  test 'start_date must be before finish_date' do
    pa = ProgrammeActivity.new
    pa.start_date = Date.new( 2020, 2, 2 )
    assert pa.valid?
    assert_equal Date.new( 2020, 2, 2 ), pa.finish_date
    pa.start_date = pa.start_date - 1
    assert pa.valid?
    pa.start_date = pa.finish_date + 1
    refute pa.valid?
    assert_includes pa.errors, :base
  end

  test 'label_with_id' do
    pa = programme_activities( :ppa_one )
    assert_equal "Activity No 1 - Prepare Document [#{ programme_activities( :ppa_one ).id }]", pa.label_with_id
    pa = programme_activities( :ppa_two )
    assert_equal "Activity No 2 - Submit Document [#{ programme_activities( :ppa_two ).id }]", pa.label_with_id
    pa.activity_label = nil
    assert_equal "[#{ programme_activities( :ppa_two ).id }]", pa.label_with_id
  end

  test 'write accessors remove leading, trailing, duplicate blanks' do
    pa = ProgrammeActivity.new
    pa.project_id = ' 1 2  3 4 '
    assert_equal '1 2 3 4', pa.project_id
    pa.activity_id = ' 1 2  3 4 '
    assert_equal '1 2 3 4', pa.activity_id
  end

end
