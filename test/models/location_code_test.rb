require 'test_helper'
class LocationCodeTest < ActiveSupport::TestCase

  test 'fixture type 0' do 
    lc = location_codes( :zero )
    refute_nil lc.code, 'code is required'
    refute_nil lc.label, 'label is required'
    assert 0, lc.loc_type
    assert_nil lc.center_point, 'center must be nil for loc_type 0'
    assert_nil lc.start_point,  'start must be nil for loc_type 0'
    assert_nil lc.end_point,    'end must be nil for loc_type 0'
    assert_nil lc.length,       'length must be nil for loc_type 0'
  end

  test 'fixture type 1' do
    lc = location_codes( :one )
    refute_nil lc.code, 'code is required'
    refute_nil lc.label, 'label is required'
    assert 1, lc.loc_type
    refute_nil lc.center_point, 'center must be given for loc_type 1'
    assert_nil lc.start_point,  'start must be nil for loc_type 1'
    assert_nil lc.end_point,    'end must be nil for loc_type 1'
    assert_nil lc.length,       'length must be nil for loc_type 1'
  end

  test 'fixture type 2' do
    lc = location_codes( :two )
    refute_nil lc.code, 'code is required'
    refute_nil lc.label, 'label is required'
    assert_equal 2,lc.loc_type
    refute_nil lc.center_point, 'center must be given for loc_type 2'
    assert_equal lc.start_point, ( lc.center_point - ( lc.length / 2))
    assert_equal lc.end_point,   ( lc.start_point + lc.length )
    assert_equal lc.length, ( lc.end_point - lc.start_point ) 
  end

  test 'default values' do
    lc = LocationCode.new
    assert_nil lc.code
    assert_nil lc.label
    assert_equal 2,lc.loc_type
    assert_nil lc.center_point
    assert_nil lc.start_point
    assert_nil lc.end_point
    assert_nil lc.length
    assert_nil lc.note
  end

  test 'code syntax' do
    xc = location_codes( :two )
    
    xc.code = ''
    refute xc.valid?
    assert_includes xc.errors, :code

    xc.code = ' '
    refute xc.valid?
    assert_includes xc.errors, :code

    xc.code = '+'
    refute xc.valid?
    assert_includes xc.errors, :code

    xc.code = '+a'
    refute xc.valid?
    assert_includes xc.errors, :code

    xc.code = '+?'
    refute xc.valid?
    assert_includes xc.errors, :code

    xc.code = '+A-Za'
    refute xc.valid?
    assert_includes xc.errors, :code

    xc.code = '+A-Z0-9.'
    assert xc.valid?
  end

  test 'code and label' do
    xc = location_codes( :two )
    xc.code = '+NEW'
    xc.label = 'Test'
    xc.valid?
    assert xc.valid?
    assert_equal '+NEW - Test', xc.code_and_label
  end

  test 'minimal validation 0' do
    lc = LocationCode.new
    refute lc.valid?
    assert_includes lc.errors, :code
    assert_includes lc.errors, :label
    lc.code = '+1'
    refute lc.valid?
    assert_includes lc.errors, :label
    lc.label = 'test'
    assert lc.valid?    
  end

  test 'loc_type is required 0' do
    lc = location_codes( :zero )
    assert lc.valid?
    lc.loc_type = nil
    refute lc.valid?
    assert_includes lc.errors, :loc_type
  end

  test 'loc_type is required 1' do
    lc = location_codes( :one )
    assert lc.valid?
    lc.loc_type = nil
    refute lc.valid?
    assert_includes lc.errors, :loc_type
  end

  test 'loc_type is required 2' do
    lc = location_codes( :two )
    assert lc.valid?
    lc.loc_type = nil
    refute lc.valid?  
    assert_includes lc.errors, :loc_type
  end

  test 'bad value for start and end' do
    lc = location_codes( :two )
    # start < end
    lc.start_point, lc.end_point = lc.end_point, lc.start_point
    refute lc.valid?
    assert_includes lc.errors, :start_point
    lc.start_point, lc.end_point = lc.end_point, lc.start_point
    assert lc.valid?
  end

  test 'bad center value' do
    lc = location_codes( :two )
    # center outside of start - end range
    lc.center_point = lc.start_point
    assert lc.valid?
    lc.center_point -= 1
    refute lc.valid?
    assert_includes lc.errors, :center_point

    lc.center_point = lc.end_point
    assert lc.valid?
    lc.center_point += 1
    refute lc.valid?
    assert_includes lc.errors, :center_point
  end

  test 'check valid value ranges' do
    lc = location_codes( :two )
    # all values present, nothing shall change
    lc.center_point = 1000
    lc.start_point = 900
    lc.end_point = 1100
    lc.length = 200
    assert lc.valid?

    # modify some values which should NOT be recomputed

    lc.center_point = lc.end_point
    assert lc.valid?
    assert_equal 1100, lc.center_point

    lc.center_point = lc.start_point
    assert lc.valid?
    assert_equal 900, lc.center_point

    # compute center from start, end, length

    lc.center_point = nil
    assert lc.valid?
    assert_equal 1000, lc.center_point

    # compute center + end from start and length

    lc.center_point = nil
    lc.end_point = nil
    assert lc.valid?
    assert_equal 1000, lc.center_point
    assert_equal 1100, lc.end_point

    # compute center + start from end and length

    lc.center_point = nil
    lc.start_point = nil
    assert lc.valid?
    assert_equal 1000, lc.center_point
    assert_equal 900, lc.start_point

    # compute center + length from start and end

    lc.center_point = nil
    lc.length = nil
    assert lc.valid?
    assert_equal 1000, lc.center_point
    assert_equal 200, lc.length

    # compute length w/o center from start and end

    lc.center_point = 1100
    lc.length = nil
    assert lc.valid?
    assert_equal 1100, lc.center_point
    assert_equal 200, lc.length

    # length cannot be computed w/o start

    lc.center_point = nil
    lc.length = nil
    lc.start_point = nil
    assert lc.valid?
    assert_nil lc.center_point
    assert_nil lc.length
    assert_nil lc.start_point
    assert_equal 1100, lc.end_point

    lc.end_point = nil
    assert lc.valid?
    assert_nil lc.center_point
    assert_nil lc.length
    assert_nil lc.start_point
    assert_nil lc.end_point

    lc.start_point = 900
    assert lc.valid?
    assert_nil lc.center_point
    assert_nil lc.length
    assert_equal 900, lc.start_point
    assert_nil lc.end_point

  end

end
