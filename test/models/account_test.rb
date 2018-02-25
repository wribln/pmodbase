require 'test_helper'
class AccountTest < ActiveSupport::TestCase

  test 'class method user user' do
    [ :one, :wop, :two, :three ].each do |aa|
      a = accounts( aa )
      refute_nil a.person_id
      assert_equal a.user_name, Account.user_name( a.id )
    end
    a = accounts( :one )
    a.person_id = people( :person_two ).id
    assert a.save, a.errors.inspect
    assert_equal a.user_name, Account.user_name( a.id )
    assert_equal a.user_name, people( :person_two ).user_name
  end

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
    refute a.valid?
    assert_includes a.errors, :person_id
    a.person_id = -1
    refute a.valid?
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
    a = accounts( :one )
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
    a = accounts( :one )
    assert_equal text_with_id( a.name, a.id ), a.name_with_id
    a.name = nil
    assert_equal "[#{ a.id }]", a.name_with_id
    a.name = ''
    assert_equal "[#{ a.id }]", a.name_with_id
  end

  test 'permitted groups' do
    a = accounts( :one )
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

    assert_equal '',a.permitted_groups( 1, :to_index  )
    assert_equal '',a.permitted_groups( 1, :to_create )
    assert_equal '',a.permitted_groups( 1, :to_read   )
    assert_equal '',a.permitted_groups( 1, :to_update )
    assert_equal '',a.permitted_groups( 1, :to_delete )

    # remove right :to_delete and test again

    p.to_delete = 0
    assert p.save
    assert_equal '',a.permitted_groups( 1, :to_index  )
    assert_equal '',a.permitted_groups( 1, :to_create )
    assert_equal '',a.permitted_groups( 1, :to_read   )
    assert_equal '',a.permitted_groups( 1, :to_update )
    assert_nil a.permitted_groups( 1, :to_delete )

    # remove right :to_update and test again

    p.to_update = 0
    assert p.save
    assert_equal '',a.permitted_groups( 1, :to_index  )
    assert_equal '',a.permitted_groups( 1, :to_create )
    assert_equal '',a.permitted_groups( 1, :to_read   )
    assert_nil a.permitted_groups( 1, :to_update )
    assert_nil a.permitted_groups( 1, :to_delete )

    # remove right :to_create and test again

    p.to_create = 0
    assert p.save
    assert_equal '',a.permitted_groups( 1, :to_index )
    assert_nil a.permitted_groups( 1, :to_create )
    assert_equal '',a.permitted_groups( 1, :to_read )
    assert_nil a.permitted_groups( 1, :to_update )
    assert_nil a.permitted_groups( 1, :to_delete )

    # now specify a specific group on the same permissions

    p.group_id = groups( :group_one ).id
    assert p.save
    assert_equal [ p.group_id ], a.permitted_groups( 1, :to_read )
    assert_nil a.permitted_groups( 1, :to_create )
    assert_equal [ p.group_id ], a.permitted_groups( 1, :to_index )
    assert_nil a.permitted_groups( 1, :to_update )
    assert_nil a.permitted_groups( 1, :to_delete )

    # now try with two groups, identical permissions

    p2 = p.dup
    p2.group_id = groups( :group_two ).id
    assert p2.save
    assert_nil a.permitted_groups( 1, :to_delete )
    assert_nil a.permitted_groups( 1, :to_update )
    assert_nil a.permitted_groups( 1, :to_create )
    apg = a.permitted_groups( 1, :to_read  )
    assert_includes apg, p.group_id
    assert_includes apg, p2.group_id
    apg = a.permitted_groups( 1, :to_index  )
    assert_includes apg, p.group_id
    assert_includes apg, p2.group_id

    # two groups, identical permissions except for :to_create

    p2.to_create = 1
    assert p2.save
    assert_nil a.permitted_groups( 1, :to_update )
    assert_nil a.permitted_groups( 1, :to_delete )
    assert_equal [ p2.group_id ], a.permitted_groups( 1, :to_create )
    apg = a.permitted_groups( 1, :to_read  )
    assert_includes apg, p.group_id
    assert_includes apg, p2.group_id
    apg = a.permitted_groups( 1, :to_index  )
    assert_includes apg, p.group_id
    assert_includes apg, p2.group_id
  end

  test 'all scopes' do
    as = Address.ff_id( addresses( :address_one ).id )
    assert_equal 1, as.length

    as = Address.ff_id( 0 )
    assert_equal 0, as.length

    as = Address.ff_label( 'Address' )
    assert_equal 2, as.length

    as = Address.ff_label( '1' )
    assert_equal 1, as.length

    as = Address.ff_label( 'foobar' )
    assert_equal 0, as.length

    as = Address.ff_address( 'Address' )
    assert_equal 2, as.length

    as = Address.ff_address( '1' )
    assert_equal 1, as.length

    as = Address.ff_address( 'foobar' )
    assert_equal 0, as.length
  end

  test 'account_info' do
    as = accounts( :one )
    assert_equal "One (Master [#{ as.id }])", as.account_info
    as = accounts( :wop )
    assert_equal "One (Account without permissions [#{ as.id }])", as.account_info
    as = accounts( :two )
    assert_equal "One (Account for testing [#{ as.id }])", as.account_info
    as = accounts( :three )
    assert_equal "One (Another Test Account [#{ as.id }])", as.account_info
  end

  test 'password should be present (nonblank)' do
    as = accounts( :one )
    as.password = as.password_confirmation = " " * 8
    refute as.valid?
    assert_includes as.errors, :password
  end

  test 'password should have a minimum length' do
    as = accounts( :one )
    as.password = as.password_confirmation = 'Abc!123'
    refute as.valid?
    assert_includes as.errors, :password
    as.password = as.password_confirmation = 'Abc!!123'
    assert as.valid?
  end

  test 'password and password_confirmation must match' do
    as = accounts( :one )
    as.password = as.password_confirmation = 'Abc!!123'
    assert as.valid?
    as.password = 'Abc//123'
    refute as.valid?
    assert_includes as.errors, :password_confirmation
  end

end