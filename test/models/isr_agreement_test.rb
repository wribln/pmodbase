require 'test_helper'
class IsrAgreementTest < ActiveSupport::TestCase

  test 'fixture 1' do 
    isa = isr_agreements( :one )
    refute_nil isa.code
    assert isa.valid?, isa.errors.messages
  end

  test 'defaults' do
    isa = IsrAgreement.new
    assert_nil isa.code
    assert_nil isa.isr_interface_id
    assert_nil isa.l_group_id
    assert_nil isa.l_owner_id
    assert_nil isa.l_deputy_id
    assert_nil isa.p_group_id
    assert_nil isa.p_owner_id
    assert_nil isa.p_deputy_id
    assert_nil isa.l_signature
    assert_nil isa.p_signature
    assert_nil isa.l_sign_time
    assert_nil isa.p_sign_time
    assert_nil isa.cfr_record_id
    assert_nil isa.def_text
    assert_equal 0, isa.ia_status
    assert_equal 0, isa.current_status
    assert_equal 0, isa.current_task
    assert_nil isa.res_steps_id
    assert_nil isa.val_steps_id
    assert_nil isa.ia_no
    assert_equal 0, isa.rev_no
    assert_nil isa.based_on_id
  end

  test 'code format' do
    isa = IsrAgreement.new
    isf = isr_interfaces( :one )

    assert_nil isa.code

    isa.isr_interface = isf
    assert_equal sprintf( "IF-%d-IA---", isf.id ), isa.code

    isa.ia_no = 1
    assert_equal sprintf( "IF-%d-IA-1--", isf.id ), isa.code

    isa.l_group_id = groups( :group_one ).id
    assert_equal sprintf( "IF-%d-IA-1-ONE-", isf.id ), isa.code

    isa.p_group_id = groups( :group_two ).id
    assert_equal sprintf( "IF-%d-IA-1-ONE-TWO", isf.id ), isa.code
  end

  test 'revision format' do
    isa = IsrAgreement.new
    assert isa.revision =~ /Rev\..0/

    isa.rev_no += 1
    assert isa.revision =~ /Rev\..1/
  end

  test 'code and revision combined' do
    isa = isr_agreements( :one )
    isa_code = isa.code
    assert_equal 0, isa.rev_no
    assert_equal isa_code, isa.code_and_revision
    isa.rev_no += 1
    assert_equal "#{ isa_code } #{ isa.revision }", isa.code_and_revision
  end

  test 'ia status labels' do
    isa = IsrAgreement.new

    isa.ia_status = nil 
    assert_nil isa.ia_status_label

    isa.ia_status = 0
    assert_equal isa.ia_status_label, IsrAgreement::ISR_IA_STATUS_LABELS[ 0 ]

    isa.ia_status = 11 # max + 1
    assert_nil isa.ia_status_label
  end

  test 'set next ia_no' do
    isa1 = isr_agreements( :one )
    assert_equal 1, isa1.ia_no

    isa2 = isa1.isr_interface.isr_agreements.build( l_group_id: isa1.l_group_id )
    isa2.set_next_ia_no
    assert_equal 2, isa2.ia_no
    assert isa2.save, isa2.errors.messages

    isa3 = isa2.isr_interface.isr_agreements.build( l_group_id: isa2.l_group_id )
    isa3.set_next_ia_no
    assert_equal 3, isa3.ia_no
    assert isa3.save

    assert_difference( 'IsrAgreement.count', -1 ){ assert isa2.destroy }

    isa4 = isa3.isr_interface.isr_agreements.build( l_group_id: isa3.l_group_id )
    isa4.set_next_ia_no
    assert isa4.save

    assert_equal 4, isa4.ia_no
    assert_equal 3, isa4.isr_interface.isr_agreements.count
  end

  test 'tia list code' do
    isa = isr_agreements( :one )
    tia_prefix = isa.code[ 0..-9 ]
    assert_equal "#{ tia_prefix }-RS", isa.tia_list_code( :res_steps )
    assert_equal "#{ tia_prefix }-VS", isa.tia_list_code( :val_steps )
    assert isa.tia_list_code( :res_steps ).length <= MAX_LENGTH_OF_CODE
    assert isa.tia_list_code( :val_steps ).length <= MAX_LENGTH_OF_CODE
    assert_raises ArgumentError do
      isa.tia_list_code( :test )
    end 
  end

  test 'tia list label' do
    isa = isr_agreements( :one )
    isa_code = isa.code
    assert_equal I18n.t( 'activerecord.attributes.isr_agreement.res_steps_label', code: isa_code ), isa.tia_list_label( :res_steps )
    assert_equal I18n.t( 'activerecord.attributes.isr_agreement.val_steps_label', code: isa_code ), isa.tia_list_label( :val_steps )
    assert_raises ArgumentError do
      isa.tia_list_label( :fail )
    end
  end

  test 'all scopes' do
    as = IsrAgreement.ff_sts( 0 )
    assert_equal 1, as.length

    as = IsrAgreement.ff_sts( 1 )
    assert_equal 0, as.length

    as = IsrAgreement.ff_wfs( '0,0' ) # ia_type, current_status
    assert_equal 1, as.length

    as = IsrAgreement.ff_wfs( '1,1' )
    assert_equal 0, as.length

    as = IsrAgreement.ff_txt( 'test' )
    assert_equal 1, as.length

    as = IsrAgreement.ff_txt( 'nothing' )
    assert_equal 0, as.length

    as = IsrAgreement.current
    assert_equal 1, as.length

    isa = isr_agreements( :one )
    isa.ia_status = 5
    assert isa.save

    as = IsrAgreement.current
    assert_equal 1, as.length

    as = IsrAgreement.ff_grp( isa.l_group_id )
    assert_equal 1, as.length

    as = IsrAgreement.ff_grp( isa.p_group_id )
    assert_equal 1, as.length

    as = IsrAgreement.ff_grp( 0 )
    assert_equal 0, as.length

    isf = isa.isr_interface
    as = IsrAgreement.ff_id( isf.id )
    assert_equal 1, as.length

    as = IsrAgreement.ff_id( 0 )
    assert_equal 0, as.length

  end

  test 'ia_type and belongs_to consistency' do
    isa = isr_agreements( :one )
    assert isa.valid?

    isa.ia_type = 1
    assert isa.invalid?
    assert_includes isa.errors, :ia_type
    assert_equal I18n.t( 'isr_interfaces.msg.inconsistent', detail: 1 ), isa.errors[ :ia_type ].first

    isa.based_on_id = 0
    assert isa.invalid?
    assert_includes isa.errors, :ia_type
    assert_equal I18n.t( 'isr_interfaces.msg.inconsistent', detail: 1 ), isa.errors[ :ia_type ].first

    isr2 = isr_interfaces( :one ).dup 
    assert isr2.save
    isa2 = isr_agreements( :one ).dup
    isa2.isr_interface_id = isr2.id
    isa2.prepare_revision( 0 )
    isa2.set_next_ia_no
    isa2.based_on_id = nil
    assert isa2.save, isa2.errors.messages

    isa.based_on = isa2
    assert isa.invalid?
    assert_includes isa.errors, :based_on_id
    assert_equal I18n.t( 'isr_interfaces.msg.inconsistent', detail: 2 ), isa.errors[ :based_on_id ].first

    isa2.isr_interface_id = isr_interfaces( :one ).id
    assert isa.invalid?
    assert_includes isa.errors, :based_on_id
    assert_equal I18n.t( 'isr_interfaces.msg.inconsistent', detail: 3 ), isa.errors[ :based_on_id ].first

    isa2.rev_no = 1
    assert isa2.save, isa2.errors.messages
  end

  test 'owners/deputies have required access' do
    isf = isr_interfaces( :one )
    isa = isf.isr_agreements.build
    isa.prepare_revision( 0 )
    isa.set_next_ia_no

    # no owner/deputy defined

    isa.l_group_id = isf.l_group_id
    assert isa.valid?, isa.errors.messages

    %w( l_owner l_deputy ).each do |u|

      # try user w/o permission

      isa.send( "#{ u }=", accounts( :wop ))
      assert isa.invalid?, "failed for #{u}"

      # set user w/ permission

      isa.send( "#{ u }=", accounts( :one ))
      assert isa.valid?, isa.errors.messages

    end

    # p_group not defined - no checks done

    %w( p_owner p_deputy ).each do |u|
      isa.send( "#{ u }=", accounts( :wop ))
      assert isa.valid?, isa.errors.messages
    end

    isa.p_group_id = isa.l_group_id
    assert isa.invalid?
    assert_includes isa.errors, :p_owner_id
    assert_includes isa.errors, :p_deputy_id

    isa.p_owner_id = accounts( :one ).id
    assert isa.invalid?
    refute_includes isa.errors, :p_owner_id
    assert_includes isa.errors, :p_deputy_id

    isa.p_deputy_id = isa.p_owner_id
    assert isa.valid?

  end

  test 'ensure that tia list is created' do
    isa = isr_agreements( :one )
    isa.res_steps_req = 1
    isa.val_steps_req = 1
    isa.l_deputy_id = isa.l_owner_id
    assert isa.valid?, isa.errors.messages
    assert_difference( 'TiaList.count', 2 ) do
      assert isa.save, isa.errors.messages
    end
    isa.reload
    # and l_owner is set as owner of the tia list
    assert_equal isa.l_owner_id, isa.res_steps.owner_account_id
    assert_equal isa.l_owner_id, isa.val_steps.owner_account_id
    assert_equal isa.l_deputy_id, isa.res_steps.deputy_account_id
    assert_equal isa.l_deputy_id, isa.val_steps.deputy_account_id
    # change accounts
    a1 = accounts( :one ) # has permissions
    a2 = accounts( :two ) # needs permissions
    pg = a2.permission4_groups.build( feature_id: FEATURE_ID_ISR_INTERFACES, group_id: 0, to_read: 1, to_update: 1 )
    assert pg.save, pg.errors.messages

    isa.l_owner_id = a2.id
    assert isa.save, isa.errors.messages
    assert_equal a2.id, isa.res_steps.owner_account_id
    assert_equal a2.id, isa.val_steps.owner_account_id
    assert_equal a1.id, isa.res_steps.deputy_account_id
    assert_equal a1.id, isa.val_steps.deputy_account_id

    isa.l_owner_id = a1.id
    isa.l_deputy_id = a2.id
    assert isa.save, isa.errors.messages
    assert_equal a1.id, isa.res_steps.owner_account_id
    assert_equal a1.id, isa.val_steps.owner_account_id
    assert_equal a2.id, isa.res_steps.deputy_account_id
    assert_equal a2.id, isa.val_steps.deputy_account_id
    # remove lists
    isa.res_steps_req = 0
    isa.val_steps_req = 0
    assert_difference( 'TiaList.count', -2 ) do
      assert isa.save, isa.errors.messages
    end

  end

  test 'agreement termination: terminate' do
    isa = isr_agreements( :one )
    isa.res_steps_req = 1
    isa.val_steps_req = 1
    assert isa.save, isa.errors.messages
    isa.reload
    isa.terminate_ia
    assert isa.valid?
    assert_equal 7, isa.ia_status
    assert isa.res_steps.archived
    assert isa.val_steps.archived
  end

  test 'agreement termination: resolved' do
    isa = isr_agreements( :one )
    isa.res_steps_req = 1
    isa.val_steps_req = 1
    assert isa.save, isa.errors.messages
    isa.reload
    isa.resolve_ia
    assert isa.save
    isa.reload
    assert_equal 2, isa.ia_status
    assert isa.res_steps.archived
    refute isa.val_steps.archived
  end

  test 'agreement termination: closed' do
    isa = isr_agreements( :one )
    isa.res_steps_req = 1
    isa.val_steps_req = 1
    assert isa.save, isa.errors.messages
    isa.reload
    isa.close_ia
    assert isa.save
    isa.reload
    assert_equal 3, isa.ia_status
    assert isa.res_steps.archived
    assert isa.val_steps.archived
  end

  test 'agreement termination: withdrawn' do
    isa = isr_agreements( :one )
    isa.res_steps_req = 1
    isa.val_steps_req = 1
    assert isa.save, isa.errors.messages
    isa.reload
    isa.withdraw
    assert isa.save
    isa.reload
    assert_equal 10, isa.ia_status
    assert_equal 6, isa.current_task
    assert_equal 9, isa.current_status
    assert isa.res_steps.archived
    assert isa.val_steps.archived
  end

  test 'set_next_rev_no' do
    isa1 = isr_agreements( :one )
    assert_equal 1, isa1.ia_no
    assert_equal 0, isa1.rev_no

    isa2 = isa1.isr_interface.isr_agreements.build( ia_no: 1, l_group_id: isa1.l_group_id )
    isa2.set_next_rev_no
    assert_equal 1, isa2.rev_no
    assert isa2.save

    isa3 = isa2.isr_interface.isr_agreements.build( ia_no: 1, l_group_id: isa2.l_group_id )
    isa3.set_next_rev_no
    assert_equal 2, isa3.rev_no
    assert isa3.save

    assert_difference( 'IsrAgreement.count', -1 ){ isa2.destroy }

    isa4 = isa3.isr_interface.isr_agreements.build( ia_no: 1, l_group_id: isa3.l_group_id )
    isa4.set_next_rev_no
    assert_equal 3, isa4.rev_no
    assert isa4.save
  end

  test 'provoke inconsistencies' do
    isa1 = isr_agreements( :one )
    isa2 = isa1.isr_interface.isr_agreements.build( ia_no: 1, l_group_id: isa1.l_group_id )
    isa2.prepare_revision( 1, isa1 )
    assert isa2.save

    # 4 - withdrawn IA may only be for revision 0

    assert_equal 1, isa2.rev_no
    isa2.ia_status = 10
    refute isa2.valid?
    assert_includes isa2.errors, :ia_status
    assert_equal '4',isa2.errors[ :ia_status ][ 0 ][ -1 ]

    # 3 - new revision must have larger rev_no

    isa2.rev_no = 0
    isa2.ia_status = 0
    refute isa2.valid?
    assert_includes isa2.errors, :based_on_id
    assert_equal '3',isa2.errors[ :based_on_id ][ 0 ][ -1 ]

    # 2 - new IA must refer to same IF as based_on IA

    isf1 = isa1.isr_interface
    isf2 = isf1.dup
    assert isf2.save

    isa1.isr_interface = isf2
    refute isa2.valid?
    assert_includes isa2.errors, :based_on_id
    assert_equal '2',isa2.errors[ :based_on_id ][ 0 ][ -1 ]

    # 1 - based_on IA must exist

    assert isa1.destroy
    refute isa2.valid?
    assert_includes isa2.errors, :ia_type
    assert_equal '1',isa2.errors[ :ia_type ][ 0 ][ -1 ]

  end

end
