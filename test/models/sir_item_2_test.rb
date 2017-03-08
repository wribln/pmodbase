require 'test_helper'
class SirItem2Test < ActiveSupport::TestCase

  %i( one two ).each do |fx|

  test "visibility fixture #{ fx }" do
    si = sir_items( fx )
    reset_visibility( si )
    si.set_visibility( nil )
    si.sir_entries.each do |se|
      refute se.is_visible?
    end

    reset_visibility( si )
    si.set_visibility( '' )
    si.sir_entries.each do |se|
      assert se.is_visible?
    end
  end

  end # loop over fixtures

  test 'complex scenario 1' do

    #                          X/nil all A  B  C  D  E  F
    #                             
    #     -> B                    -   1  2  1  1  1  1  1
    #          -> C               -   1  -  2  1  1  -  -
    #               -> D          -   1  -  -  2  1  -  -
    #                  D          -   1  -  -  -  3  -  -
    #             C <-            -   1  -  -  2  1  -  -
    #        B <-                 -   1  -  2  1  1  -  -
    #        B                    -   1  -  3  -  -  -  -
    #          -> D               -   1  -  1  -  1  1  1
    #               -> E          -   1  -  -  -  2  1  1
    #                    -> F     -   1  -  -  -  -  2  1
    #                  E <-       -   1  -  -  -  -  1  1
    #             D <-            -   1  -  -  -  2  1  1
    #        B <-                 -   1  -  1  -  1  1  1
    # (A) <-                      -   1  1  2  1  1  1  1
    #
    group_cat = group_categories( :group_category_one )

    group_a, group_b, group_c, group_d, group_e, group_f = nil
    assert_difference( 'Group.count', 6 ) do
      group_a = group_cat.groups.create( code: 'A', label: 'Group A' )
      group_b = group_cat.groups.create( code: 'B', label: 'Group B' )
      group_c = group_cat.groups.create( code: 'C', label: 'Group C' )
      group_d = group_cat.groups.create( code: 'D', label: 'Group D' )
      group_e = group_cat.groups.create( code: 'E', label: 'Group E' )
      group_f = group_cat.groups.create( code: 'F', label: 'Group F' )
    end
    group_x = groups( :group_one )

    sl = nil
    assert_difference( 'SirLog.count', 1 ) do 
      sl = SirLog.create( code: 'ABC', label: 'ABC-Test', owner_account: accounts( :one ))
    end

    si = nil
    assert_difference( 'SirItem.count', 1 ) do
      si = sl.sir_items.create( group: group_a, label: 'complex item', seqno: 1 )
      assert si.valid?, si.errors.messages
    end

    group_stack = [ si.group_id ]
    assert_equal 0, SirItem.depth( group_stack )

    # no entries: 1

    se = nil
    assert_difference( 'SirEntry.count', 1 ) do
      se = si.sir_entries.create( rec_type: 0,
        orig_group: si.group, 
        resp_group: group_b )
    end
    assert_equal 1, SirItem.depth!( group_stack, se )
    assert_equal 1, SirItem.depth( group_stack )

    reset_visibility( si )

    si.set_visibility( nil )
    assert_equal [ 0 ], visibility_to_a( si )

    si.set_visibility( '' )
    assert_equal [ 1 ], visibility_to_a( si )

    si.set_visibility([ group_x.id ])
    assert_equal [ 0 ], visibility_to_a( si )

    si.set_visibility([ group_a.id ])
    assert_equal [ 2 ], visibility_to_a( si )

    # no entries: 3

    assert_difference( 'SirEntry.count', 2 ) do
      se = si.sir_entries.create( rec_type: 0, orig_group: group_b, resp_group: group_c )
      assert_equal 2, SirItem.depth!( group_stack, se )
      se = si.sir_entries.create( rec_type: 0, orig_group: group_c, resp_group: group_d )
      assert_equal 3, SirItem.depth!( group_stack, se )
    end
    assert_equal 3, SirItem.depth( group_stack )

    reset_visibility( si )

    si.set_visibility( nil )
    assert_equal [ 0, 0, 0 ], visibility_to_a( si )

    si.set_visibility( '' )
    assert_equal [ 1, 1, 1 ], visibility_to_a( si )

    si.set_visibility([ group_x.id ])
    assert_equal [ 0, 0, 0 ], visibility_to_a( si )

    si.set_visibility([ group_a.id ])
    assert_equal [ 2, 0, 0 ], visibility_to_a( si )

    si.set_visibility([ group_b.id ])
    assert_equal [ 1, 2, 0 ], visibility_to_a( si )

    si.set_visibility([ group_c.id ])
    assert_equal [ 1, 1, 2 ], visibility_to_a( si )

    si.set_visibility([ group_d.id ])
    assert_equal [ 1, 1, 1 ], visibility_to_a( si )

    # no entries: 5

    assert_difference( 'SirEntry.count', 2 ) do
      se = si.sir_entries.create( rec_type: 1, resp_group: group_d )
      assert_equal 3, SirItem.depth!( group_stack, se )
      se = si.sir_entries.create( rec_type: 2, orig_group: group_d, resp_group: group_c )
      assert_equal 2, SirItem.depth!( group_stack, se )
    end
    assert_equal 2, SirItem.depth( group_stack )

    reset_visibility( si )

    si.set_visibility( nil )
    assert_equal [ 0, 0, 0, 0, 0 ], visibility_to_a( si )

    si.set_visibility( '' )
    assert_equal [ 1, 1, 1, 1, 1 ], visibility_to_a( si )

    si.set_visibility([ group_x.id ])
    assert_equal [ 0, 0, 0, 0, 0 ], visibility_to_a( si )

    si.set_visibility([ group_a.id ])
    assert_equal [ 2, 0, 0, 0, 0 ], visibility_to_a( si )

    si.set_visibility([ group_b.id ])
    assert_equal [ 1, 2, 0, 0, 0 ], visibility_to_a( si )

    si.set_visibility([ group_c.id ])
    assert_equal [ 1, 1, 2, 0, 2 ], visibility_to_a( si )

    si.set_visibility([ group_d.id ])
    assert_equal [ 1, 1, 1, 3, 1 ], visibility_to_a( si )

    # make it complete

    assert_difference( 'SirEntry.count', 9 ) do
      se = si.sir_entries.create( rec_type: 2, orig_group: group_c, resp_group: group_b )
      assert_equal 1, SirItem.depth!( group_stack, se )
      se = si.sir_entries.create( rec_type: 1, orig_group: group_b, resp_group: group_b )
      assert_equal 1, SirItem.depth!( group_stack, se )
      se = si.sir_entries.create( rec_type: 0, orig_group: group_b, resp_group: group_d )
      assert_equal 2, SirItem.depth!( group_stack, se )
      se = si.sir_entries.create( rec_type: 0, orig_group: group_d, resp_group: group_e )
      assert_equal 3, SirItem.depth!( group_stack, se )
      se = si.sir_entries.create( rec_type: 0, orig_group: group_e, resp_group: group_f )
      assert_equal 4, SirItem.depth!( group_stack, se )
      se = si.sir_entries.create( rec_type: 2, orig_group: group_f, resp_group: group_e )
      assert_equal 3, SirItem.depth!( group_stack, se )
      se = si.sir_entries.create( rec_type: 2, orig_group: group_e, resp_group: group_d )
      assert_equal 2, SirItem.depth!( group_stack, se )
      se = si.sir_entries.create( rec_type: 2, orig_group: group_d, resp_group: group_b )
      assert_equal 1, SirItem.depth!( group_stack, se )
      se = si.sir_entries.create( rec_type: 2, orig_group: group_b, resp_group: group_a )
      assert_equal 0, SirItem.depth!( group_stack, se )
    end      
    assert_equal 0, SirItem.depth( group_stack )

    reset_visibility( si )

    si.set_visibility( nil )
    assert_equal [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], visibility_to_a( si )

    si.set_visibility( '' )
    assert_equal [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ], visibility_to_a( si )

    si.set_visibility([ group_x.id ])
    assert_equal [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ], visibility_to_a( si )

    si.set_visibility([ group_a.id ])
    assert_equal [ 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2 ], visibility_to_a( si )

    si.set_visibility([ group_b.id ])
    assert_equal [ 1, 2, 0, 0, 0, 2, 3, 2, 0, 0, 0, 0, 2, 1 ], visibility_to_a( si )

    si.set_visibility([ group_c.id ])
    assert_equal [ 1, 1, 2, 0, 2, 1, 0, 0, 0, 0, 0, 0, 0, 1 ], visibility_to_a( si )

    si.set_visibility([ group_d.id ])
    assert_equal [ 1, 1, 1, 3, 1, 1, 0, 1, 2, 0, 0, 2, 1, 1 ], visibility_to_a( si )

    si.set_visibility([ group_e.id ])
    assert_equal [ 1, 0, 0, 0, 0, 0, 0, 1, 1, 2, 2, 1, 1, 1 ], visibility_to_a( si )

    si.set_visibility([ group_f.id ])
    assert_equal [ 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1 ], visibility_to_a( si )

    si.set_visibility([ group_b.id, group_f.id ])
    assert_equal [ 1, 2, 0, 0, 0, 2, 3, 1, 1, 1, 1, 1, 1, 1 ], visibility_to_a( si )
  end

  def reset_visibility( si )
    si.sir_entries.each{ |se| se.visibility = nil }
  end

  def visibility_to_a( si )
    si.sir_entries.map{ |se| se.visibility }
  end

end