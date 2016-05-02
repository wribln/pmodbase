require 'test_helper'
class PcpItemTest < ActiveSupport::TestCase

  test 'fixture 1' do
    pi = pcp_items( :one )
    assert pi.valid?
    assert pi.pcp_subject.id, pcp_subjects( :one ).id
    assert pi.pcp_step.id, pcp_steps( :one ).id
    assert 1, pi.seqno
    assert 0, pi.item_status
  end

  test 'fixture 2' do
    pi = pcp_items( :two )
    assert pi.valid?
    assert pi.pcp_subject.id, pcp_subjects( :one ).id
    assert pi.pcp_step.id, pcp_steps( :one ).id
    assert 2, pi.seqno
    assert 1, pi.item_status
  end

  test 'defaults' do
    pi = PcpItem.new
    refute pi.valid?
    assert_includes pi.errors, :pcp_subject_id
    assert_includes pi.errors, :pcp_step_id
    assert_includes pi.errors, :description
    pi.pcp_subject = pcp_subjects( :one )
    pi.pcp_step = pcp_steps( :one )
    pi.description = 'foobar'
    assert pi.valid?, pi.errors.messages
  end

  test 'parent subject must exist' do
    pi = pcp_items( :one )
    pi.pcp_subject_id = nil
    refute pi.valid?
    assert_includes pi.errors, :pcp_subject_id
    pi.pcp_subject_id = 0
    refute pi.valid?
    assert_includes pi.errors, :pcp_subject_id
    pi.pcp_subject_id = pcp_subjects( :one ).id
    assert pi.valid?, pi.errors.messages
  end

  test 'parent step must exist' do
    pi = pcp_items( :one )
    pi.pcp_step_id = nil
    refute pi.valid?
    assert_includes pi.errors, :pcp_step_id
    pi.pcp_step_id = 0
    refute pi.valid?
    assert_includes pi.errors, :pcp_step_id
    pi.pcp_step_id = pcp_subjects( :one ).id
    assert pi.valid?, pi.errors.messages
  end

  test 'parent subject and step must be related' do
    pi = pcp_items( :one )

    # create new subject

    ps = PcpSubject.new
    ps.pcp_category_id = pcp_subjects( :one ).pcp_category_id
    ps.title = 'foobar'
    px = PcpStep.new
    assert_difference( 'PcpSubject.count', 1 )do
      assert ps.save, ps.errors.messages
      px.pcp_subject_id = ps.id
      assert px.save, px.errors.messages
    end

    pi.pcp_subject_id = ps.id
    refute pi.valid?
    assert_includes pi.errors, :base
    refute_includes pi.errors, :pcp_subject_id

    pi.pcp_step_id = px.id
    assert pi.valid?

    pi.pcp_subject_id = pcp_subjects( :one ).id
    refute pi.valid?
    assert_includes pi.errors, :base
    refute_includes pi.errors, :pcp_step_id

    pi.pcp_step_id = pcp_steps( :one ).id
    assert pi.valid?
  end

  test 'next sequence number' do
    pi = PcpItem.new
    pi.pcp_subject_id = pcp_items( :two ).pcp_subject_id
    pi.set_next_seqno
    assert_equal 3, pi.seqno
    pi.description = 'foobar'
    pi.pcp_step_id = pcp_items( :two ).pcp_step_id
    assert pi.save
    pn = pi.dup
    pn.set_next_seqno
    assert_equal 4, pn.seqno
    assert_difference( 'PcpItem.count', -1 ) do
      pcp_items( :one ).destroy
    end
    pn.set_next_seqno
    assert_equal 4, pn.seqno
    assert_difference( 'PcpItem.count', -1 ) do
      pcp_items( :two ).destroy
    end
    pn.set_next_seqno
    assert_equal 4, pn.seqno
    assert_difference( 'PcpItem.count', -1 ) do
      pi.destroy
    end
    assert_equal 0, PcpItem.count
    pn.set_next_seqno
    assert_equal 1, pn.seqno

  end



end
