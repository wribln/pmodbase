require 'test_helper'
class OrlSubjectTest < ActiveSupport::TestCase

  test 'check fixture' do
    os = orl_subjects( :one )
    refute_empty os.desc
    refute_empty os.note
    refute_empty os.project_doc_id
    refute_empty os.report_doc_id
    refute_nil os.o_group_id
    refute_nil os.r_group_id
    refute_nil os.orl_category_id
    refute_nil os.o_owner_id
    refute_nil os.r_owner_id
    assert_nil os.o_deputy_id
    assert_nil os.r_deputy_id
    assert os.valid?, os.errors.messages
  end

  test 'create new subject with defaults' do
    os = OrlSubject.new
    refute os.valid?
    assert_includes os.errors, :orl_category_id
    refute_includes os.errors, :o_owner_id
    refute_includes os.errors, :r_owner_id
    refute_includes os.errors, :o_group_id
    refute_includes os.errors, :r_group_id
    refute_includes os.errors, :o_deputy_id
    refute_includes os.errors, :r_deputy_id
    refute_includes os.errors, :desc
    refute_includes os.errors, :note
    refute_includes os.errors, :project_doc_id
    refute_includes os.errors, :report_doc_id
  end

  test 'new object inherits defaults from given orl_category' do
    os = OrlSubject.new
    oc = orl_categories( :one )
    os.orl_category = oc
    assert os.valid?
    assert_equal os.o_group_id, oc.o_group_id
    assert_equal os.r_group_id, oc.r_group_id
    assert_equal os.o_owner_id, oc.o_owner_id
    assert_equal os.r_owner_id, oc.r_owner_id
    assert_equal os.o_deputy_id, oc.o_deputy_id
    assert_equal os.r_deputy_id, oc.r_deputy_id
  end

  test 'check required attributes' do
    os = OrlSubject.new
    os.orl_category_id = orl_categories( :one ).id
    os.o_owner_id = accounts( :account_one ).id
    os.r_owner_id = accounts( :account_one ).id
    os.o_group_id = groups( :group_one ).id
    os.r_group_id = groups( :group_one ).id
    assert os.valid?, os.errors.messages
  end

  test 'orl_category must be valid' do
    os = orl_subjects( :one )
    os.orl_category_id = nil 
    refute os.valid?
    assert_includes os.errors, :orl_category_id
    os.orl_category_id = 0
    refute os.valid?
    assert_includes os.errors, :orl_category_id
    os.orl_category_id = orl_categories( :one ).id 
    assert os.valid?
    oc = orl_categories( :one ).dup 
    oc.save
    os.orl_category_id = oc.id
    assert os.valid?
    oc.destroy
    refute os.valid?, os.errors.messages
  end

  test 'o_owner must have access to respective group' do
    os = orl_subjects( :one )
    os.o_owner_id = accounts( :account_wop ).id
    refute os.valid?
    assert_includes os.errors, :o_owner_id
    os.o_owner_id = nil
    refute os.valid?
    assert_includes os.errors, :o_owner_id
    os.o_owner_id = accounts( :account_one ).id    
    assert os.valid?
  end

  # same test but with specific group ( :account_one has access
  # to all groups, :account_two only for group_two )

  test 'o_owner must have access to specified group' do
    os = orl_subjects( :one )
    assert_equal groups( :group_one ).id, os.o_group_id
    os.o_owner_id = accounts( :account_two ).id
    refute os.valid?#
    os.o_group_id = groups( :group_two ).id
    assert os.valid?
  end

  test 'r_owner must have access to respective group' do
    os = orl_subjects( :one )
    os.r_owner_id = accounts( :account_wop ).id
    refute os.valid?
    assert_includes os.errors, :r_owner_id
    os.r_owner_id = nil
    refute os.valid?
    assert_includes os.errors, :r_owner_id
    os.r_owner_id = accounts( :account_one ).id    
    assert os.valid?
  end

  # same test but with specific group ( :account_one has access
  # to all groups, :account_two only for group_two )

  test 'r_owner must have access to specified group' do
    os = orl_subjects( :one )
    assert_equal groups( :group_one ).id, os.r_group_id
    os.r_owner_id = accounts( :account_two ).id
    refute os.valid?#
    os.r_group_id = groups( :group_two ).id
    assert os.valid?
  end

  test 'o_deputy - if given - must have access to respective group' do
    os = orl_subjects( :one )
    os.o_deputy_id = nil
    assert os.valid?
    os.o_deputy_id = accounts( :account_wop ).id
    refute os.valid?
    assert_includes os.errors, :o_deputy_id
    os.o_deputy_id = accounts( :account_one ).id
    assert os.valid?
  end

  test 'r_deputy - if given - must have access to respective group' do
    os = orl_subjects( :one )
    os.r_deputy_id = nil
    assert os.valid?
    os.r_deputy_id = accounts( :account_wop ).id
    refute os.valid?
    assert_includes os.errors, :r_deputy_id
    os.r_deputy_id = accounts( :account_one ).id
    assert os.valid?
  end

end
