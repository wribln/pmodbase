require 'test_helper'
class PersonTest < ActiveSupport::TestCase

  test "formal name with id" do
    p = people( :person_one )
    assert_equal text_with_id( p.name, p.id ), p.name_with_id
  end

  test "test default settings" do
    p = Person.new
    assert_equal p.formal_name, '', 'should be empty string'
    assert_equal p.informal_name, '', 'should be empty string'
    assert_equal p.email, '', 'should be empty string'
    assert p.involved, 'should be true'
    assert_not p.save, 'at least one name must be given'
  end

  test "at least formal name must be given" do
    assert_difference( 'Person.count' ) do
      p = Person.new
      p.formal_name = 'John N. Doe'
      assert_equal p.informal_name, ''
      assert_equal p.name_with_id, 'John N. Doe'
      assert p.save, 'should be OK'
    end
  end

  test "at least informal name must be given" do
    assert_difference( 'Person.count' ) do
      p = Person.new
      p.informal_name = 'John'
      assert_equal p.formal_name, ''
      assert_equal p.name_with_id, 'John'
      assert p.save, 'should be OK'
    end
  end

  test "provide both names" do
    assert_difference( 'Person.count' ) do
      p = Person.new
      p.informal_name = 'John'
      p.formal_name = 'John N. Doe'
      assert_equal p.name_with_id, 'John N. Doe'
      assert p.save, 'should be OK'
    end
  end

end
