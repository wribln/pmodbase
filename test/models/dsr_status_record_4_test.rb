require 'test_helper'
class DsrStatusRecordTest4 < ActiveSupport::TestCase

  # add missing tests for 'possible to derive (this)':
  # they basically just call this method to ensure that
  # the method can be used in standard situations

  test 'possible_to_derive' do
    d = dsr_status_records( :dsr_rec_one )
    refute d.possible_to_derive?
    d.sub_frequency = 0
    d.dsr_doc_group_id = nil 
    d.quantity = 0
    d.weight = 0
    refute d.possible_to_derive?
    d.sub_frequency = 2
    d.dsr_doc_group_id = dsr_doc_groups( :dsr_group_one ).id 
    d.quantity = 1
    d.weight = 1.0
    assert d.possible_to_derive?
  end

  test 'possible_to_derive_this' do
    d1 = dsr_status_records( :dsr_rec_two )
    d1.sub_frequency = 2
    d1.dsr_doc_group_id = dsr_doc_groups( :dsr_group_one ).id
    d1.quantity = 1
    d1.weight = 1.0
    assert d1.possible_to_derive?
    d2 = DsrStatusRecord.new 
    refute d2.possible_to_derive?
    d2.sub_frequency = nil
    d2.quantity = nil
    d2.dsr_doc_group_id = nil
    refute d2.possible_to_derive?
    d2.sub_frequency = 0
    refute d1.possible_to_derive_this( d2 )
    d2.quantity = 0
    refute d1.possible_to_derive_this( d2 )
    d2.sub_frequency = 1
    d2.quantity = 1
    refute d1.possible_to_derive_this( d2 )
    d2.dsr_doc_group_id = d1.dsr_doc_group_id
    assert d1.possible_to_derive_this( d2 )
  end

end
