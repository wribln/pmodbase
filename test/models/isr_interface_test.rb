require 'test_helper'
class IsrInterfaceTest < ActiveSupport::TestCase

  test 'fixture 1' do
    isr = isr_interfaces( :one )
    refute_nil isr.if_code
    assert isr.valid?, isr.errors.messages
  end

end
