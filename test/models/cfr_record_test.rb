require 'test_helper'
class CfrRecordTest < ActiveSupport::TestCase

  test 'fixture 1 - minimum' do
    cfr = cfr_records( :one )
    assert_equal 0, cfr.conf_level
    refute_nil cfr.title
    assert cfr.valid?, cfr.errors.messages
  end

  test 'fixture 2 - maximum' do
    cfr = cfr_records( :two )
    assert_equal 3, cfr.conf_level
    assert_equal groups( :group_one ).id, cfr.group_id
    refute_nil cfr.title
    refute_nil cfr.note
    refute_nil cfr.doc_version
    refute_nil cfr.doc_date
    refute_nil cfr.doc_owner
    refute_nil cfr.extension
    assert_equal cfr_file_types( :two ).id, cfr.cfr_file_type_id
    refute_nil cfr.hash_value
    refute_nil cfr.hash_function
    assert_equal cfr_locations( :one ).id, cfr.main_location_id
    assert cfr.valid?, cfr.errors.messages
  end

  test 'defaults' do
    cfr = CfrRecord.new
    assert_equal 1, cfr.conf_level
    assert_nil cfr.group_id
    assert_nil cfr.title
    assert_nil cfr.note
    assert_nil cfr.doc_version
    assert_nil cfr.doc_date
    assert_nil cfr.doc_owner
    assert_nil cfr.extension
    assert_nil cfr.cfr_file_type_id
    assert_nil cfr.hash_function
    assert_nil cfr.hash_value
    assert_nil cfr.main_location_id
    refute cfr.valid?
    assert_includes cfr.errors, :title
    cfr.title = 'test'
    assert cfr.valid?
  end

  test 'hash values' do
    cfr = cfr_records( :one )

    # empty OK - will be stored as nil

    cfr.hash_value = ''
    assert_nil cfr.hash_value

    cfr.hash_value = ' '
    assert_nil cfr.hash_value

    # hash value w/o function cannot be accepted

    ok_hash = '123456789012345678901234567890ab'
    cfr.hash_value = ok_hash
    assert_equal ok_hash, cfr.hash_value
    refute cfr.valid?
    assert_includes cfr.errors, :hash_value
    cfr.hash_function = 0 # MD5
    assert cfr.valid?

    # blanks will be removed

    cfr.hash_value = '12 34 56 78 90 12 34 56 78 90 12 34 56 78 90 ab'
    assert_equal ok_hash, cfr.hash_value

    # upper case map to lower case

    cfr.hash_value = '12 34 56 78 90 12 34 56 78 90 12 34 56 78 90 AB'
    assert_equal ok_hash, cfr.hash_value

    # check for invalid characters

    cfr.hash_value = '12 34 56 78 90 12 34 56 78 90 12 34 56 78 90 AG'
    refute cfr.valid?
    assert_includes cfr.errors, :hash_value   

  end

  test 'hash function value combination' do
    cfr = cfr_records( :one )

    # nil + nil = ok

    assert_nil cfr.hash_function
    assert_nil cfr.hash_value
    assert cfr.valid?

    cfr.hash_value = ''
    assert cfr.valid?

    cfr.hash_value = ' '
    assert cfr.valid?

    # function + nil = ok

    cfr.hash_function = 0
    assert cfr.valid?

    cfr.hash_value = ''
    assert cfr.valid?

    cfr.hash_value = nil
    assert cfr.valid?

    # nil + value = error

    cfr.hash_function = nil
    cfr.hash_value = '123456789012345678901234567890ab'
    refute cfr.valid?
    assert_includes cfr.errors, :hash_value

  end

  test 'get label for group' do
    cfr = cfr_records( :one )

    assert 0, cfr.group_id
    assert cfr.group_code.blank?

    cfr.group_id = groups( :group_one ).id
    assert_equal cfr.group_code, groups( :group_one ).code
  end

  test 'given file type must exist' do
    cfr = cfr_records( :one )
    assert_nil cfr.cfr_file_type_id
    assert cfr.valid?

    cfr.cfr_file_type_id = 0
    refute cfr.valid?
    assert_includes cfr.errors, :cfr_file_type_id

    cfr.cfr_file_type = cfr_file_types( :two )
    assert cfr.valid?
  end

  test 'given main location must exist' do
    cfr = cfr_records( :one )
    assert_nil cfr.main_location_id
    assert cfr.valid?

    cfr.main_location_id = 0
    cfr.given_main_location_ok
    assert_includes cfr.errors, :main_location_id

    cfr.main_location_id = cfr_locations( :one ).id
    cfr.given_main_location_ok
    assert_includes cfr.errors, :main_location_id

    cfr = cfr_records( :two )
    cfr.main_location_id = cfr_locations( :one ).id
    cfr.given_main_location_ok
    assert cfr.valid?, cfr.errors.messages
  end

  test 'link to file' do
    cfr = cfr_records( :one )
    assert_nil cfr.main_location_uri
    cfr = cfr_records( :two )
    assert_equal 'file://X:\blne058a\TS_TK_Proj\DNK_ODN\somewhere\over\the\rainbow\way\up\high.pdf', cfr.main_location_uri
  end

  test 'reject if location empty' do
    cfr = CfrRecord.new({ title: 'test', cfr_locations_attributes: 
      [{ uri: '', doc_version: '', doc_code: '', file_name: '', is_main_location: true }]})
    assert_equal 0, cfr.cfr_locations.length
    cfr = CfrRecord.new({ title: 'test', cfr_locations_attributes: [{ is_main_location: true }]})
    assert_equal 0, cfr.cfr_locations.length
    cfr = CfrRecord.new({ title: 'test', cfr_locations_attributes: [{ uri:         'x' }]})
    assert_equal 1, cfr.cfr_locations.length
    cfr = CfrRecord.new({ title: 'test', cfr_locations_attributes: [{ doc_version: 'x' }]})
    assert_equal 1, cfr.cfr_locations.length
    cfr = CfrRecord.new({ title: 'test', cfr_locations_attributes: [{ doc_code:    'x' }]})
    assert_equal 1, cfr.cfr_locations.length
    cfr = CfrRecord.new({ title: 'test', cfr_locations_attributes: [{ file_name:   'x' }]})
    assert_equal 1, cfr.cfr_locations.length
  end

  test 'update main location' do
    cfr = cfr_records( :one )
    l1 = CfrLocation.new({ cfr_record: cfr, uri: 'test 1', is_main_location: false })
    assert l1.save, l1.errors.messages

    assert_nil cfr.main_location_id
    cfr.update_main_location
    cfr.reload
    assert_nil cfr.main_location_id

    l1.is_main_location = true
    assert l1.save
    cfr.reload
    assert cfr.valid?

    assert_nil cfr.main_location_id
    cfr.update_main_location
    cfr.reload
    assert_equal l1.id, cfr.main_location_id

    l2 = CfrLocation.new({ cfr_record: cfr, uri: 'test 2', is_main_location: true })
    assert l2.save, l2.errors.messages
    refute cfr.valid? # because we have two main locations
    assert_includes cfr.errors, :base

    l1.is_main_location = false
    l1.save
    cfr.reload
    cfr.given_main_location_ok
    # because main_location_id points to wrong, non-main record
    assert_includes cfr.errors, :main_location_id

    cfr.update_main_location
    cfr.reload
    assert_equal l2.id, cfr.main_location_id
    assert cfr.valid?, cfr.errors.messages
  end

  test 'get title and doc id' do
    cfr = cfr_records( :one )
    td = CfrRecord.get_title_and_doc_id( cfr.id )
    assert_equal td.first, cfr.title
    assert_nil td.second
    
    cfr = cfr_records( :two )
    cfl = cfr_locations( :one )
    td = CfrRecord.get_title_and_doc_id( cfr.id )
    assert_equal 2, td.length
    assert_equal td.first, cfr.title
    assert_equal td.second, cfl.doc_code

    # add other location with doc_code

    cfn = cfr.cfr_locations.build( doc_code: 'ONE-MORE' )
    assert cfn.save

    # ... should give same result as above

    td = CfrRecord.get_title_and_doc_id( cfr.id )
    assert_equal 2, td.length
    assert_equal td.first, cfr.title
    assert_equal td.second, cfl.doc_code

    # remove doc_code from main location

    cfl.doc_code = nil
    assert cfl.save

    # should give new doc code

    td = CfrRecord.get_title_and_doc_id( cfr.id )
    assert_equal 2, td.length
    assert_equal td.first, cfr.title
    assert_equal td.second, cfn.doc_code
  end

end
