require 'test_helper'
class PersonTest < ActiveSupport::TestCase

  test 'formal name with id' do
    p = people( :person_one )
    assert_equal text_with_id( p.name, p.id ), p.name_with_id
  end

  test 'test default settings' do
    p = Person.new
    assert_nil p.formal_name
    assert_nil p.informal_name
    assert_nil p.email
    assert p.involved, 'should be true'
    refute p.valid?
    assert_includes p.errors, :base
    assert_includes p.errors, :email
  end

  test 'at least formal name must be given' do
    assert_difference( 'Person.count' ) do
      p = Person.new
      p.formal_name = 'John N. Doe'
      p.email = 'john.doe@pmodbase.com'
      assert_nil p.informal_name
      assert_equal p.name_with_id, 'John N. Doe'
      assert p.save, 'should be OK'
    end
  end

  test 'at least informal name must be given' do
    p = Person.new
    p.informal_name = 'John'
    p.email = 'john.doe@pmodbase.com'
    assert_nil p.formal_name
    assert_equal p.name_with_id, 'John'
    assert p.valid?
  end

  test 'provide both names' do
    assert_difference( 'Person.count' ) do
      p = Person.new
      p.informal_name = 'John'
      p.formal_name = 'John N. Doe'
      p.email = 'john.doe@pmodbase.com'
      assert_equal p.name_with_id, 'John N. Doe'
      assert p.save, 'should be OK'
    end
  end

  test 'email must be unique' do
    p = Person.new
    p.informal_name = 'test'
    p.email = people( :person_one ).email
    refute p.valid?
    assert_includes p.errors, :email
    p.email = people( :person_two ).email
    refute p.valid?
    assert_includes p.errors, :email
    p.email = 'x.' + p.email
    assert p.valid?
  end

  test 'email is handled lowercase only' do
    p = Person.new
    p.informal_name = 'test'
    p.email = 'mr.tester@pmodbase.com'
    assert p.valid?
    p.save
    p = p.dup
    refute p.valid?
    assert_includes p.errors, :email
    p.email = 'Mr.Tester@PMODBase.com'
    refute p.valid?
    assert_includes p.errors, :email
    p.email = 'Mrs.Tester@PMODBase.com'
    assert p.valid?
    assert_equal p.email, 'mrs.tester@pmodbase.com'
  end

  test 'name and user_name' do
    p = Person.new    
    p.informal_name = 'informal'
    [ nil, '' ].each do |f_n|
      p.formal_name = f_n
      assert_equal 'informal', p.name
      assert_equal 'informal', p.user_name
      assert_equal 'informal', p.name_with_id
    end

    p.formal_name = 'formal'
    [ nil, '' ].each do |i_n|
      p.informal_name = i_n
      assert_equal 'formal', p.name
      assert_equal 'formal', p.user_name
      assert_equal 'formal', p.name_with_id
    end
  end

end
