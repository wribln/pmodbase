require 'test_helper'
class AccountTest < ActiveSupport::TestCase

  test 'add new account, check defaults' do
    a = Account.new
    assert_nil a.name,'name'
    assert_nil a.password_digest, 'password_digest'
    assert a.active, 'active'
    refute a.keep_base_open, 'keep_base_open'
    assert_nil a.person_id, 'person_id'
  end

  test 'given person must exist' do
    a = Account.new
    a.person_id = nil
    assert_not a.valid?
    assert_includes a.errors, :person_id
    assert_not a.valid?
    assert_includes a.errors, :person_id
  end

  test 'new account must have name and password: 0. both nil' do
    a = Account.new
    a.person_id = people( :person_one ).id
    assert_not a.valid?
  end

  test 'new account must have name and password: 1. name only' do
    a = Account.new
    a.person_id = people( :person_one ).id
    a.name = 'test'
    assert_not a.valid?
  end

  test 'new account must have name and password: 2. reset to all nil' do
    a = Account.new
    a.person_id = people( :person_one ).id
    a.name = nil
    assert_not a.valid?
  end

  test 'new account must have name and password: 3. password only' do
    a = Account.new
    a.person_id = people( :person_one ).id
    a.password_digest = 'Passw0rd!'
    assert_not a.valid?
  end

  test 'new account must have name and password: 4. reset all nil' do
    a = Account.new
    a.person_id = people( :person_one ).id
    a.password_digest = nil
    assert_not a.valid?
  end

  test 'new account must have name and password: 5. both set' do
    a = Account.new
    a.person_id = people( :person_one ).id
    a.name = 'test'        
    a.password = 'Passw0rd!'
    a.password_digest = 'Passw0rd!'
    assert a.valid?
  end

  test 'account must have at least 3 character name' do
    a = Account.new
    a.person_id = people( :person_one ).id
    a.name = '1'
    assert_not a.valid?
  end

  test 'account name must be unique' do
    a = accounts( :account_one )
    b = Account.new
    b.person_id = a.person_id
    b.name = a.name
    b.password_digest = 'test'
    assert_not b.valid?
    assert_includes b.errors, :name
  end

  test 'method name_with_id' do
    a = Account.new
    assert_equal '', a.name_with_id
    a.name = 'test'
    assert_equal 'test', a.name_with_id
    a = accounts( :account_one )
    assert_equal text_with_id( a.name, a.id ), a.name_with_id
    a.name = nil
    assert_equal "[#{ a.id }]", a.name_with_id
    a.name = ''
    assert_equal "[#{ a.id }]", a.name_with_id
  end

  test 'permitted groups' do
    a = accounts( :account_one )
    p = permission4_groups( :permission4_group_1 )
    # we should have full access
    assert_equal p.account.id, a.id
    assert_equal 0, p.group_id
    assert_equal 1, p.to_index
    assert_equal 1, p.to_create
    assert_equal 1, p.to_read
    assert_equal 1, p.to_update
    assert_equal 1, p.to_delete
    assert a.active

    # access for all actions, for all groups

    assert_equal '',a.permitted_groups( 1, :to_index, :some_id )
    assert_equal '',a.permitted_groups( 1, :to_create, :some_id )
    assert_equal '',a.permitted_groups( 1, :to_read, :some_id )
    assert_equal '',a.permitted_groups( 1, :to_update, :some_id )
    assert_equal '',a.permitted_groups( 1, :to_delete, :some_id )

    # remove right :to_delete and test again

    p.to_delete = 0
    assert p.save
    assert_equal '',a.permitted_groups( 1, :to_index, :some_id )
    assert_equal '',a.permitted_groups( 1, :to_create, :some_id )
    assert_equal '',a.permitted_groups( 1, :to_read, :some_id )
    assert_equal '',a.permitted_groups( 1, :to_update, :some_id )
    assert_nil a.permitted_groups( 1, :to_delete, :some_id )

    # remove right :to_update and test again

    p.to_update = 0
    assert p.save
    assert_equal '',a.permitted_groups( 1, :to_index, :some_id )
    assert_equal '',a.permitted_groups( 1, :to_create, :some_id )
    assert_equal '',a.permitted_groups( 1, :to_read, :some_id )
    assert_nil a.permitted_groups( 1, :to_update, :some_id )
    assert_nil a.permitted_groups( 1, :to_delete, :some_id )

    # remove right :to_create and test again

    p.to_create = 0
    assert p.save
    assert_equal '',a.permitted_groups( 1, :to_index, :some_id )
    assert_nil a.permitted_groups( 1, :to_create, :some_id )
    assert_equal '',a.permitted_groups( 1, :to_read, :some_id )
    assert_nil a.permitted_groups( 1, :to_update, :some_id )
    assert_nil a.permitted_groups( 1, :to_delete, :some_id )

    # now specify a specific group on the same permissions

    p.group_id = groups( :group_one ).id
    assert p.save
    assert_equal "some_id IN (#{ p.group_id })", a.permitted_groups( 1, :to_read, :some_id )
    assert_nil a.permitted_groups( 1, :to_create, :some_id )
    assert_equal "some_id IN (#{ p.group_id })", a.permitted_groups( 1, :to_index, :some_id )
    assert_nil a.permitted_groups( 1, :to_update, :some_id )
    assert_nil a.permitted_groups( 1, :to_delete, :some_id )

    # now try with two groups, identical permissions

    p2 = p.dup
    p2.group_id = groups( :group_two ).id
    gl = [ p.group_id, p2.group_id ].sort.join( ',')
    assert p2.save
    assert_nil a.permitted_groups( 1, :to_delete, :some_id )
    assert_nil a.permitted_groups( 1, :to_update, :some_id )
    assert_nil a.permitted_groups( 1, :to_create, :some_id )
    assert_equal "some_id IN (#{ gl })", a.permitted_groups( 1, :to_read, :some_id )
    assert_equal "some_id IN (#{ gl })", a.permitted_groups( 1, :to_index, :some_id )

    # two groups, identical permissions except for :to_create

    p2.to_create = 1
    assert p2.save
    assert_nil a.permitted_groups( 1, :to_update, :some_id )
    assert_nil a.permitted_groups( 1, :to_delete, :some_id )
    assert_equal "some_id IN (#{ p2.group_id })", a.permitted_groups( 1, :to_create, :some_id )
    assert_equal "some_id IN (#{ gl })", a.permitted_groups( 1, :to_read, :some_id )
    assert_equal "some_id IN (#{ gl })", a.permitted_groups( 1, :to_index, :some_id )
  end

end
