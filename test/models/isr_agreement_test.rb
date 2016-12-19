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
    assert_equal 'Rev. 0', isa.revision

    isa.rev_no += 1
    assert_equal 'Rev. 1', isa.revision
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

    isa.ia_status = 8 # max + 1
    assert_nil isa.ia_status_label
  end

  test 'set next ia_no' do
    isa1 = isr_agreements( :one )
    assert_equal 1, isa1.ia_no
    isa2 = isa1.isr_interface.isr_agreements.build
    isa2.set_next_ia_no
    assert_equal 2, isa2.ia_no
  end

  test 'tia list code' do
    isa = isr_agreements( :one )
    tia_prefix = isa.code[ 0..-9 ]
    assert_equal "#{ tia_prefix }-RS", isa.tia_list_code( :res_steps )
    assert_equal "#{ tia_prefix }-VS", isa.tia_list_code( :val_steps )
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

    as = IsrAgreement.individual
    assert_equal 1, as.length

    as = IsrAgreement.isr_active
    assert_equal 1, as.length

    isa = isr_agreements( :one )
    isa.ia_status = 5
    assert isa.save

    as = IsrAgreement.individual
    assert_equal 0, as.length

    as = IsrAgreement.isr_active
    assert_equal 0, as.length

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

end
