require 'test_helper'
class PcpItemTest < ActiveSupport::TestCase

  test 'fixture 1' do
    pi = pcp_items( :one )
    assert pi.valid?
    assert pi.pcp_subject.id, pcp_subjects( :one ).id
    assert pi.pcp_step.id, pcp_steps( :one ).id
    assert_equal 1, pi.seqno
    assert_equal 1, pi.pub_assmt
    assert_equal 0, pi.new_assmt
    assert_equal 1, pi.assessment
    assert_equal 0, pi.valid_assessment?
  end

  test 'fixture 2' do
    pi = pcp_items( :two )
    assert pi.valid?
    assert pi.pcp_subject.id, pcp_subjects( :one ).id
    assert pi.pcp_step.id, pcp_steps( :one ).id
    assert_equal 2, pi.seqno
    assert_equal 0, pi.pub_assmt
    assert_equal 1, pi.new_assmt
    assert_equal 0, pi.assessment
    assert_equal 0, pi.valid_assessment?
  end

  test 'defaults' do
    pi = PcpItem.new
    refute pi.valid?
    assert_includes pi.errors, :pcp_subject_id
    assert_includes pi.errors, :pcp_step_id
    assert_includes pi.errors, :description
    assert_includes pi.errors, :author
    pi.pcp_subject = pcp_subjects( :one )
    pi.pcp_step = pcp_steps( :one )
    pi.seqno = 1
    pi.description = 'foobar'
    pi.author = 'I'
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
    ps.p_owner_id = accounts( :account_one ).id
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
    pi.author = 'tester'
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

  test 'get released items' do
    s = pcp_subjects( :one )
    pr = PcpItem.released( s )
    assert_equal 2, pr.count
    pr.each do |p|
      assert p.released?
    end
    pn = s.pcp_items.new
    pn.pcp_step = pcp_steps( :two )
    pn.set_next_seqno
    pn.author = 'me'
    pn.description = 'foobar'
    assert pn.save, pn.errors.inspect
    pr = PcpItem.released( s )
    assert_equal 2, pr.count
    pr.each do |p|
      assert p.released?
    end
  end

  test 'assessments' do
    cu = accounts( :account_one )
    # create new item
    ps = pcp_steps( :two_one )
    pi = nil
    assert_difference( 'PcpItem.count' )do
      pi = ps.pcp_items.create( pcp_subject: ps.pcp_subject, description: 'foobar', seqno: 1, author: 'me' )
    end
    assert_equal 0, pi.valid_assessment?, pi.inspect
    assert_equal 0, pi.new_assmt
    assert_equal 0, pi.assessment
    assert_nil pi.pub_assmt
    # change of :assessment should also change :new_assmt here
    pi.assessment = 2
    assert_equal 2, pi.new_assmt
    # add internal comment to PCP Item w/o prior release
    pc0 = nil
    assert_difference( 'PcpComment.count' )do
      pc0 = pi.pcp_comments.create( description: 'Step 0, Comment 0', pcp_step: ps, author: 'me', assessment: 1 )
    end
    pi.reload
    assert_equal 0, pi.valid_assessment?, pi.inspect
    assert_nil pi.pub_assmt
    assert_equal 2, pi.new_assmt
    assert_equal 2, pi.assessment
    # make last comment public
    pc0.make_public
    pi.reload
    assert_equal 0, pi.valid_assessment?, pi.inspect
    assert_nil pi.pub_assmt
    assert_equal 1, pi.new_assmt
    assert_equal 2, pi.assessment
    # change assessment of comment
    pc0.assessment = 2
    assert pc0.save, pc0.errors.inspect
    assert_equal 0, pi.valid_assessment?, pi.inspect
    assert_nil pi.pub_assmt
    assert_equal 2, pi.new_assmt
    assert_equal 2, pi.assessment
    # release item with a new step
    ps_new = PcpStep.new( pcp_subject: ps.pcp_subject )
    ps_new.create_release_from( ps, cu )
    ps.set_release_data( cu )
    assert_difference( 'PcpStep.count' )do
      assert ps.save, ps.errors.inspect
      assert ps_new.save, ps_new.errors.inspect
    end
    ps = ps_new
    assert_no_difference( 'PcpItem.count' )do
      pi.release_item
      assert pi.save, pi.errors.inspect
    end
    assert_equal 0, pi.valid_assessment?, pi.inspect
    assert_equal 2, pi.pub_assmt
    assert_equal 2, pi.new_assmt
    assert_equal 2, pi.assessment
    # change of :assessment should not modify :new_assmt anymore
    pi.assessment = 0
    assert_equal 2, pi.new_assmt
    assert_equal 0, pi.valid_assessment?, pi.inspect
    # therefore, we change it back
    pi.assessment = 2
    assert_equal 0, pi.valid_assessment?, pi.inspect
    # add internal comment #1
    pc1 = nil
    assert_difference( 'PcpComment.count' )do
      pc1 = pi.pcp_comments.create( description: 'Step 1, Comment 1', pcp_step: ps, author: 'me', assessment: 1 )
    end
    pi.reload
    assert_equal 0, pi.valid_assessment?, pi.inspect
    assert_equal 2, pi.pub_assmt
    assert_equal 1, pi.new_assmt
    assert_equal 2, pi.assessment
    # add internal comment #2
    pc2 = nil
    assert_difference( 'PcpComment.count' )do
      pc2 = pi.pcp_comments.create( description: 'Step 1, Comment 2', pcp_step: ps, author: 'me', assessment: 2 )
    end
    pi.reload
    assert_equal 0, pi.valid_assessment?, pi.inspect
    assert_equal 2, pi.pub_assmt
    assert_equal 2, pi.new_assmt
    assert_equal 2, pi.assessment
    # make comment #1 public - this is NOT the implemented process:
    # there only the last comment should be modified ...
    pc1.make_public
    pi.reload
    assert_equal 0, pi.valid_assessment?, pi.inspect
    assert_equal 2, pi.pub_assmt
    assert_equal 1, pi.new_assmt
    assert_equal 2, pi.assessment
    # now delete first comment
    assert_difference( 'PcpComment.count', -1 ){ pc1.delete }
    pi.update_new_assmt( nil )
    pi.reload
    assert_equal 0, pi.valid_assessment?, pi.inspect
    assert_equal 2, pi.pub_assmt
    assert_equal 2, pi.new_assmt
    assert_equal 2, pi.assessment
    # make one more comment and set it to public
    pc3 = nil
    assert_difference( 'PcpComment.count' )do
      pc3 = pi.pcp_comments.create( description: 'Step 1, Comment 3', pcp_step: ps, author: 'me', assessment: 1, is_public: true )
    end
    pi.reload
    assert_equal 0, pi.valid_assessment?, pi.inspect
    assert_equal 2, pi.pub_assmt
    assert_equal 1, pi.new_assmt
    assert_equal 2, pi.assessment
    # final comment, internal
    pc4 = nil
    assert_difference( 'PcpComment.count' )do
      pc4 = pi.pcp_comments.create( description: 'Step 1, Comment 4', pcp_step: ps, author: 'me', assessment: 2, is_public: false )
    end
    pi.reload
    assert_equal 0, pi.valid_assessment?, pi.inspect
    assert_equal 2, pi.pub_assmt
    assert_equal 1, pi.new_assmt
    assert_equal 2, pi.assessment
    # now, release this step and start a new one
    ps_new = PcpStep.new( pcp_subject: ps.pcp_subject )
    ps_new.create_release_from( ps, cu )
    ps.set_release_data( cu )
    assert_difference( 'PcpStep.count' )do
      assert ps.save, ps.errors.inspect
      assert ps_new.save, ps_new.errors.inspect
    end
    ps = ps_new
    assert_no_difference( 'PcpItem.count' )do
      pi.release_item
      assert pi.save, pi.errors.inspect
    end
    # we should have new_assmt from the previous step as new pub_assmt
    assert_equal 0, pi.valid_assessment?, pi.inspect
    assert_equal 1, pi.pub_assmt
    assert_equal 1, pi.new_assmt
    assert_equal 2, pi.assessment
  end

end
