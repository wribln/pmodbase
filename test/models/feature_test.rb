require 'test_helper'
class FeatureTest < ActiveSupport::TestCase

  test 'ensure defaults' do
    f = Feature.new
    assert_nil f.code
    assert_nil f.feature_category_id
    assert_nil f.label
    assert_equal 0, f.seqno
    assert_equal 0, f.access_level
  end

  test 'required attributes' do
    f = features( :feature_one )
    assert f.valid?
  end

  test 'required attribute code' do
    f = features( :feature_one )
    f.code = nil 
    assert_not f.valid?
  end

  test 'required attribute feature_category_id' do
    f = features( :feature_one )
    f.feature_category_id = nil
    assert_not f.valid?
  end

  test 'required attribute seqno' do
    f = features( :feature_one )
    f.code = nil
    assert_not f.valid?
  end

  test 'required attribute access_level' do
    f = features( :feature_one )
    f.access_level = nil
    assert_not f.valid?
  end

  test 'label with id' do
    f = Feature.new
    assert_equal '', f.label_with_id
    f.label = '123'
    assert_equal '123', f.label_with_id
    f = features( :feature_one )
    assert_equal text_with_id( f.label, f.id ), f.label_with_id
  end

  test 'format of code' do
    f = features( :feature_one )
    f.code = '?'
    assert_not f.valid?
    assert_includes f.errors, :code
    f.code = '/'
    assert_not f.valid?
    assert_includes f.errors, :code
    f.code = '\\'
    assert_not f.valid?
    assert_includes f.errors, :code
    f.code = 'A-Z'
    assert_not f.valid?
    assert_includes f.errors, :code
    f.code = '(0)'
    assert_not f.valid?
    assert_includes f.errors, :code
    f.code = '[1]'    
    assert_not f.valid?
    assert_includes f.errors, :code
    f.code = 'A'
    assert f.valid?
    f.code = '0'
    assert f.valid?
    f.code = '_'
    assert f.valid?
  end

  test 'uniqueness of code' do
    f = features( :feature_one ).dup
    refute f.valid?
    assert_includes f.errors, :code
  end

  test 'feature category must exist - non given' do
    f = features( :feature_one )
    f.feature_category_id = nil
    assert_not f.valid?, 'must be specified'
    assert_includes f.errors, :feature_category_id
  end

  test 'feature category must exist - non-existing' do
    f = features( :feature_one )
    f.feature_category_id = 0
    assert_not f.valid?
    assert_includes f.errors, :feature_category_id
  end

  test 'access_level range' do
    f = features( :feature_one )
    f.code = 'SGP' # need some valid routing here
    f.access_level = -1
    assert_not f.valid?, 'access_level -1 is not acceptable'
    assert_includes f.errors, :access_level
    max_access_level = ApplicationController::FEATURE_ACCESS_MAX
    (0..max_access_level).each do |l|
        f.access_level = l
        assert f.valid?, "access_level #{l} is acceptable"
    end
    f.access_level = max_access_level + 1
    assert_not f.valid?, "access_level #{ f.access_level } is not acceptable"
    assert_includes f.errors, :access_level
  end

  test 'feature category with id' do
    f = features( :feature_one )
    c = feature_categories( :feature_category_one )
    f.feature_category_id = c.id
    assert_equal text_with_id( c.label, c.id ), f.feature_category_with_id
  end

  test 'access level methods' do
    f = Feature.new
    f.access_level = nil
    assert f.no_user_access?
    assert_not f.access_to_index?
    assert_not f.access_to_view?
    assert f.no_direct_access?
    f.access_level = 0
    assert f.no_user_access?
    assert_not f.access_to_index?
    assert_not f.access_to_view?
    assert f.no_direct_access?
    f.access_level = 1
    assert_not f.no_user_access?
    assert_not f.access_to_index?
    assert_not f.no_direct_access?
    assert_not f.access_to_view?
    f.access_level = 2
    assert_not f.no_user_access?
    assert f.access_to_index?
    assert_not f.no_direct_access?
    assert_not f.access_to_view?
    f.access_level = 4
    assert_not f.no_user_access?
    assert f.access_to_index?
    assert_not f.no_direct_access?
    assert f.access_to_view?
    f.access_level = 14
    assert_not f.no_user_access?
    assert f.access_to_view?
    assert f.access_to_index?
    assert_not f.no_direct_access?
    f.access_level = 16
    assert_not f.no_user_access?
    assert f.access_to_index?
    assert_not f.no_direct_access?
    assert f.access_to_view?
    f.access_level = 33
    assert_not f.no_user_access?
    assert_not f.access_to_index?
    assert f.no_direct_access?
    assert_not f.access_to_view?
    f.access_level = 34
    assert_not f.no_user_access?
    assert f.access_to_index?
    assert f.no_direct_access?
    assert_not f.access_to_view?
    f.access_level = 38
    assert_not f.no_user_access?
    assert f.access_to_index?
    assert f.no_direct_access?
    assert f.access_to_view?
    f.access_level = 48
    assert_not f.no_user_access?
    assert f.access_to_index?
    assert f.no_direct_access?
    assert f.access_to_view?
  end

  test 'control level methods and labels' do
    f = Feature.new
    f.control_level = nil
    assert_not f.access_by_group?
    f.control_level = 0
    assert_not f.access_by_group?
    f.control_level = 1
    assert f.access_by_group?
    f.control_level = 2
    assert_not f.access_by_group?
    f.control_level = 3
    assert f.access_by_group?
    f.control_level = 4
    assert_not f.access_by_group?
    f.control_level = 5
    assert f.access_by_group?

    fl = Feature::FEATURE_CONTROL_LEVELS
    assert_equal ( 5 + 1 ), fl.count
  end

end
