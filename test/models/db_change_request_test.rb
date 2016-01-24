require 'test_helper'

class DbChangeRequestTest < ActiveSupport::TestCase

  test "default settings" do
    dbcr = DbChangeRequest.new
    assert_equal 0, dbcr.status
    assert_nil dbcr.requesting_account_id
    assert_nil dbcr.responsible_account_id
    assert_nil dbcr.feature_id
    assert_nil dbcr.detail
    assert_nil dbcr.action
    assert_nil dbcr.uri
    assert_nil dbcr.request_text
  end

  test "ensure status dimensions" do
    assert_equal 4, DbChangeRequest::DBCR_STATUS_LABELS.size
    assert_equal 'new', DbChangeRequest::DBCR_STATUS_LABELS[ 0 ]
    assert_equal 'open', DbChangeRequest::DBCR_STATUS_LABELS[ 1 ]
    assert_equal 'waiting', DbChangeRequest::DBCR_STATUS_LABELS[ 2 ]
    assert_equal 'closed', DbChangeRequest::DBCR_STATUS_LABELS[ 3 ]
  end

  test "status label with id" do
    dbcr = DbChangeRequest.new
    dbcr.status = 0
    assert_equal text_with_id( 'new',     0 ), dbcr.status_label_with_id
    dbcr.status = 1
    assert_equal text_with_id( 'open',    1 ), dbcr.status_label_with_id
    dbcr.status = 2
    assert_equal text_with_id( 'waiting', 2 ), dbcr.status_label_with_id
    dbcr.status = 3
    assert_equal text_with_id( 'closed',  3 ), dbcr.status_label_with_id
  end

  test "feature with id" do
    dbcr = db_change_requests( :dbcr_one )
    f = features( :feature_one )
    dbcr.feature_id = f.id
    assert_equal text_with_id( f.label, f.id ), dbcr.feature_label_with_id
    dbcr.feature_id = nil
    assert_equal "", dbcr.feature_label_with_id 
  end

  test "requestor with id" do
    dbcr = DbChangeRequest.new
    a = accounts( :account_one )
    dbcr.requesting_account_id = a.id
    p = Person.find( a.person_id )
    assert_equal text_with_id( p.name, p.id ), dbcr.requestor_with_id
    dbcr.requesting_account_id = nil
    assert_equal '', dbcr.requestor_with_id
    dbcr.requesting_account_id = 0
    assert_equal '[0]', dbcr.requestor_with_id
  end

  test "responsible with id" do
    dbcr = DbChangeRequest.new
    a = accounts( :account_one )
    dbcr.responsible_account_id = a.id
    p = Person.find( a.person_id )
    assert_equal text_with_id( p.name, p.id ), dbcr.responsible_with_id
    dbcr.responsible_account_id = nil
    assert_equal '', dbcr.responsible_with_id
    dbcr.responsible_account_id = 0
    assert_equal '[0]', dbcr.responsible_with_id
  end

  test "required attributes" do
    dbcr = DbChangeRequest.new
    assert_not dbcr.valid?
    assert_includes dbcr.errors, :requesting_account_id
    assert_includes dbcr.errors, :request_text
  end

  test "required attributes (requesting account id)" do
    dbcr = db_change_requests( :dbcr_one )
    assert dbcr.valid?
    
    dbcr.requesting_account_id = nil
    assert_not dbcr.valid?
    assert_includes dbcr.errors, :requesting_account_id

    dbcr.requesting_account_id = 0
    assert_not dbcr.valid?
    assert_includes dbcr.errors, :requesting_account_id
  end

  test "optional attribute valid (responsible_account_id)" do
    dbcr = db_change_requests( :dbcr_one )
    dbcr.responsible_account_id = nil
    assert dbcr.valid?

    dbcr.responsible_account_id = 0
    assert_not dbcr.valid?
    assert_includes dbcr.errors, :responsible_account_id

    dbcr.responsible_account_id = dbcr.requesting_account_id
    assert dbcr.valid?
  end    

  test "required attributes (request text)" do
    dbcr = db_change_requests( :dbcr_one )
    assert dbcr.valid?
    dbcr.request_text = nil
    assert_not dbcr.valid?
    dbcr.request_text = ""
    assert_not dbcr.valid?
    dbcr.request_text = " "
    assert_not dbcr.valid?
    dbcr.request_text = "              "
    assert_not dbcr.valid?
    dbcr.request_text = "."
    assert dbcr.valid?    
  end

  test "stats" do
    assert_equal 2, DbChangeRequest.count
    assert_equal 2, DbChangeRequest.where( status: 0 ).count
    assert_equal [['Database Change Requests', 'Total', 2], ['new', 2]], DbChangeRequest.get_stats
  end

end
