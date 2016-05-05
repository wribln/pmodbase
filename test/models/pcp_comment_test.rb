require 'test_helper'
class PcpCommentTest < ActiveSupport::TestCase

  test 'fixture 1' do
    pc = pcp_comments( :one )
    refute_nil pc.description
    refute_nil pc.author
    refute_nil pc.assessment
    assert pc.is_public
    assert pc.valid?, pc.errors.messages
  end

  test 'fixture 2' do
    pc = pcp_comments( :two )
    refute_nil pc.description
    refute_nil pc.author
    refute_nil pc.assessment
    assert pc.is_public
    assert pc.valid?, pc.errors.messages
  end

  test 'defaults' do
    pc = PcpComment.new
    refute pc.is_public
    refute pc.valid?
    assert_includes pc.errors, :pcp_step_id
    assert_includes pc.errors, :pcp_item_id

    pc.pcp_step_id = pcp_steps( :two ).id 
    pc.pcp_item_id = pcp_items( :one ).id
    assert pc.valid?, pc.errors.messages
  end

end
