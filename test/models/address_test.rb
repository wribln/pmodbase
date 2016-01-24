require 'test_helper'
class AddressTest < ActiveSupport::TestCase

  test "label_with_id" do
     a = addresses(:address_one)
     assert_equal text_with_id( a.label, a.id ), a.label_with_id
     a = addresses(:address_two)
     assert_equal text_with_id( a.label, a.id ), a.label_with_id
  end

  test "remove leading, trailing, and duplicate blanks" do

    a = Address.new
    ts1 = "test 1"
    ts2 = "test 2"

    a.label = " #{ts1}"
    assert_equal a.label, ts1

    a.label = " #{ts1} "
    assert_equal a.label, ts1

    a.label = "\n#{ts1}\n"
    assert_equal a.label, ts1

    a.label = "  #{ts1}  #{ts2}  "
    assert_equal a.label, "#{ts1} #{ts2}"

    a.label = " \n #{ts1} \n #{ts2} \n " 
    assert_equal a.label, "#{ts1} \n #{ts2}"

  end

  test "address label must be unique" do

    a = addresses( :address_one )
    assert a.valid?

    a.id = nil
    assert_not a.valid?

    a.label = "other"
    assert a.valid?

  end

end
