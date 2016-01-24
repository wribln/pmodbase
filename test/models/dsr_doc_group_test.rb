require 'test_helper'
class DsrDocGroupTest < ActiveSupport::TestCase

  test 'fixture 1' do
    dg = dsr_doc_groups( :dsr_group_one )
    refute_nil dg.code
    refute_nil dg.title
    assert_equal dg.group_id, groups( :group_one ).id
    assert dg.valid?
  end

  test 'fixture 2' do
    dg = dsr_doc_groups( :dsr_group_two )
    refute_nil dg.code
    refute_nil dg.title
    assert_equal dg.group_id, groups( :group_two ).id
    assert dg.valid?
  end

  test 'fixture 1 group must not be equal to fixture 2 group' do
    # we need this for other tests in DsrStatusRecord
    assert_not_equal dsr_doc_groups( :dsr_group_one ).group_id, dsr_doc_groups( :dsr_group_two ).group_id
  end

  test 'defaults' do
    dg = DsrDocGroup.new
    assert_nil dg.group
    assert_nil dg.code
    assert_nil dg.title
  end

  test 'minimum' do
    dg = DsrDocGroup.new
    refute dg.valid?
    assert_includes dg.errors, :group_id
    assert_includes dg.errors, :code
    assert_includes dg.errors, :title
  end

  test 'group must exist' do
    dg = dsr_doc_groups( :dsr_group_one )

    dg.group_id = nil 
    refute dg.valid?, 'group_id must exist'
    assert_includes dg.errors,  :group_id

    dg.group_id = 0
    refute dg.valid?, 'group_id must exist'
    assert_includes dg.errors,  :group_id
  end

  test 'title' do
    dg = dsr_doc_groups( :dsr_group_one )

    dg.title = ''
    refute dg.valid?, 'title must not be empty'    

    dg.title = '  a  b  c  '
    assert dg.valid?
    assert_equal 'a b c', dg.title
  end

  test 'code' do
    dg = dsr_doc_groups( :dsr_group_one )

    dg.code = ''
    refute dg.valid?, 'code must not be empty'    

    dg.code = '  a  b  c  '
    assert dg.valid?
    assert_equal 'a b c', dg.code
  end

end
