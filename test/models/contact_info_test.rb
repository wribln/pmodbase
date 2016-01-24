require 'test_helper'
class ContactInfoTest < ActiveSupport::TestCase

  test "default values" do
    ci = ContactInfo.new
    assert_nil ci.person_id
    assert_nil ci.info_type
    ci.person_id = people( :person_one ).id
    ci.info_type = "Other"
    assert ci.valid?
    assert_equal ci.department,""
    assert_equal ci.detail_location,""
    assert_equal ci.phone_no_fixed,""
    assert_equal ci.phone_no_mobile,""
  end

  test "given person must exist" do
    ci = ContactInfo.new
    assert_not ci.valid?
    assert_includes ci.errors, :person_id

    ci.person_id = 0
    assert_not ci.valid?
    assert_includes ci.errors, :person_id
  end

  test "given address must exist" do
    ci = ContactInfo.new
    ci.address_id = 0
    assert_not ci.valid?
    assert_includes ci.errors, :address_id
  end

  test "type of contact info must be unique for each user" do
    ci = contact_infos( :one )
    assert ci.valid?

    ci.id = nil
    assert_not ci.valid?

    ci.info_type = "Other"
    assert ci.valid?

    ci.info_type = contact_infos( :two ).info_type
    assert_not ci.valid?

    ci.info_type = "new"
    assert ci.valid?
  end

  test "person related to this contact info must exist" do
    p = Person.new
    p.informal_name = "Test"
    assert p.save

    pid = p.id
    assert p.destroy

    ci = contact_infos( :one )
    assert ci.valid?

    ci.person_id = pid
    assert_not ci.valid?
  end

  test "if specified, an address must exist" do

    a = Address.new
    a.label = "new"
    assert a.valid?
    assert a.save

    aid = a.id
    assert a.destroy
    
    ci = contact_infos( :one )
    assert ci.valid?
    
    ci.address_id = a.id
    assert_not ci.valid?
  
  end

end
