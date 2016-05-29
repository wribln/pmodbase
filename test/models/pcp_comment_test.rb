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

  test 'fixture 3' do
    pc = pcp_comments( :three )
    refute_nil pc.description
    refute_nil pc.author
    refute_nil pc.assessment
    refute pc.is_public
    assert pc.valid?, pc.errors.messages
  end

  test 'defaults' do
    pc = PcpComment.new
    refute pc.is_public
    refute pc.valid?
    assert_includes pc.errors, :pcp_step_id
    assert_includes pc.errors, :pcp_item_id
    assert_includes pc.errors, :description
    assert_includes pc.errors, :author

    pc.pcp_step_id = pcp_steps( :two ).id 
    pc.pcp_item_id = pcp_items( :one ).id
    pc.description = 'foobar'
    pc.author = 'tester'
    assert pc.valid?, pc.errors.messages
  end

  test 'scopes' do
    assert 0, PcpComment.for_step( pcp_steps( :one )).count
    assert 3, PcpComment.for_step( pcp_steps( :two )).count
    assert 0, pcp_items( :one ).pcp_comments.for_step( pcp_steps( :one )).count
    assert 1, pcp_items( :one ).pcp_comments.for_step( pcp_steps( :two )).count
    assert 0, pcp_items( :two ).pcp_comments.for_step( pcp_steps( :one )).count
    assert 2, pcp_items( :two ).pcp_comments.for_step( pcp_steps( :two )).count

    assert 2, PcpComment.is_public.count
    assert 1, pcp_items( :one ).pcp_comments.is_public.count
    assert 1, pcp_items( :two ).pcp_comments.is_public.count
  end

  test 'make public' do
    pc = PcpComment.where( is_public: false ).first
    assert_difference( 'PcpComment.is_public.count' ) do
      pc.make_public
    end
  end

  test 'making a comment public should trigger update_item' do
    pc = PcpComment.where( is_public: false ).first
    refute_equal pc.assessment, pc.pcp_item.new_assmt
    
    pc.is_public = true
    assert pc.update_item_flag, 'update_item_flag should be true'
    pc.save
    assert_equal pc.assessment, pc.pcp_item.new_assmt

    pc.is_public = false
    assert pc.update_item_flag, 'update_item_flag should be true'
    pc.save
  end

end
