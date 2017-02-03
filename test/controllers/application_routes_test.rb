require 'test_helper'
class ApplicationRoutesTest < ActionController::TestCase

  # permitted action prefix:

  @@action_prefix = %w( index info stats new add create update destroy show edit )

  # test all standard resources:

  @my_resources = [
    %w( A1C A1Codes ),
    %w( A2C A2Codes ),
    %w( A3C A3Codes ),
    %w( A4C A4Codes ),
    %w( A5C A5Codes ),
    %w( A6C A6Codes ),
    %w( A7C A7Codes ),
    %w( A8C A8Codes ),
    %w( AAA Abbreviations ),
    %w( ANP Accounts ),
    %w( ADT Addresses ),
    %w( CCI ContactInfos ),
    %w( CNC CountryNames ),
    %w( ACR DBChangeRequests ),
    %w( SC2 DccCodes ),
    %w( DSR DsrStatusRecords ),
    %w( DDG DsrDocGroups ),
    %w( DSB DsrSubmissions ),
    %w( FIT Features ),
    %w( FCT FeatureCategories ),
    %w( SCF FunctionCodes ),
    %w( GLO GlossaryItems ),
    %w( GRP Groups ),
    %w( GCT GroupCategories ),
    %w( HTG Hashtags ),
    %w( HLD Holidays ),
    %w( SCL LocationCodes ),
    %w( NLN NetworkLines ),
    %w( NST NetworkStations ),
    %w( NSO NetworkStops ),
    %w( PCC PcpCategories ),
    %w( PCS PcpSubjects ),
    %w( PCA PcpAllSubjects ),
    %w( APT People ),
    %w( PPC PhaseCodes ),
    %w( SCP ProductCodes ),
    %w( PPA ProgrammeActivities ),
    %w( RNC RegionNames ),
    %w( RPP Responsibilities ),
    %w( RCD RfcDocuments ),
    %w( RSR RfcStatusRecords ),
    %w( SDL SDocumentLogs ),
    %w( SCV ServiceCodes ),
    %w( SPC SiemensPhases ),
    %w( SSO StandardsBodies ),
    %w( SGP SubmissionGroups ),
    %w( ATL AllTiaLists ),
    %w( MTL MyTiaLists ),
    %w( MTI MyTiaItems ),
    %w( MCR MyChangeRequests ),
    %w( UNC UnitNames ),
    %w( WLK WebLinks ),
    %w( CFS CfrRelationships ),
    %w( CFR CfrRecords ),
    %w( CFU CfrLocationTypes ),
    %w( CFT CfrFileTypes ),
    %w( ISR IsrInterfaces ),
    %w( SIL SirLogs )
    ]

  @my_resources.each do |r|
    test "standard resource routing #{ r[0] } to #{ r[1] }" do

      p = Feature.create_target(r[ 0 ])
      c = r[1].underscore

      check_routing( 'get',    "#{ p }"        , c, 'index'   )
      check_routing( 'get',    "#{ p }/new"    , c, 'new'     )
      check_routing( 'post',   "#{ p }"        , c, 'create'  )
      check_routing( 'get',    "#{ p }/1"      , c, 'show'    , id: '1' )
      check_routing( 'get',    "#{ p }/1/edit" , c, 'edit'    , id: '1' )
      check_routing( 'put',    "#{ p }/1"      , c, 'update'  , id: '1' )
      check_routing( 'delete', "#{ p }/1"      , c, 'destroy' , id: '1' )
    end
  end

  test 'mtl nested routing' do
    [ %w( oti our_tia_items ) ].each do |r|
      check_routing( 'get',    "mtl/1/#{ r[ 0 ] }"    , r[ 1 ], 'index',  my_tia_list_id: '1' )
      check_routing( 'post',   "mtl/1/#{ r[ 0 ] }"    , r[ 1 ], 'create', my_tia_list_id: '1' )
      check_routing( 'get',    "mtl/1/#{ r[ 0 ] }/new", r[ 1 ], 'new',    my_tia_list_id: '1' )
  
      check_routing( 'get',    "#{ r[ 0 ]}/1"         , r[ 1 ], 'show',    id: '1' )
      check_routing( 'get',    "#{ r[ 0 ]}/1/edit"    , r[ 1 ], 'edit',    id: '1' )
      check_routing( 'put',    "#{ r[ 0 ]}/1"         , r[ 1 ], 'update',  id: '1' )
      check_routing( 'delete', "#{ r[ 0 ]}/1"         , r[ 1 ], 'destroy', id: '1' )
    end
  end

  test 'special routes: cfr_records' do
    check_routing( 'get', '/cfr/1/all', 'cfr_records', 'show_all', id: '1' )
  end

  test 'special routes: tia_items' do
    [ %w( mti my_tia_items ), %w( oti our_tia_items )].each do |r|
      check_routing( 'get', "/#{ r[ 0 ]}/1/info", r[ 1 ], 'info', id: '1' )
    end
  end

  test 'pcs nested routing' do
    [ %w( pci pcp_items ), %w( pcm pcp_members )].each do |r|
      check_routing( 'get',    "pcs/1/#{ r[ 0 ] }"    , r[ 1 ], 'index',   pcp_subject_id: '1' )
      check_routing( 'post',   "pcs/1/#{ r[ 0 ] }"    , r[ 1 ], 'create',  pcp_subject_id: '1' )
      check_routing( 'get',    "pcs/1/#{ r[ 0 ] }/new", r[ 1 ], 'new',     pcp_subject_id: '1' )
  
      check_routing( 'get',    "#{ r[ 0 ]}/1"         , r[ 1 ], 'show',    id: '1' )
      check_routing( 'get',    "#{ r[ 0 ]}/1/edit"    , r[ 1 ], 'edit',    id: '1' )
      check_routing( 'put',    "#{ r[ 0 ]}/1"         , r[ 1 ], 'update',  id: '1' )
      check_routing( 'delete', "#{ r[ 0 ]}/1"         , r[ 1 ], 'destroy', id: '1' )
    end
  end

  test 'special routes: home/root' do
  #  check_routing( 'get',  '/'             , 'home', 'index'   )
  #  check_routing( 'post', '/home/signon'  , 'home', 'signon'  )
  #  check_routing( 'get',  '/home/signoff' , 'home', 'signoff' )
    assert_routing({ method: 'get',  path: '/'             },{ controller: 'home', action: 'index'   })
    assert_routing({ method: 'post', path: '/home/signon'  },{ controller: 'home', action: 'signon'  })
    assert_routing({ method: 'get',  path: '/home/signoff' },{ controller: 'home', action: 'signoff' })
  end

  test 'special routes: CDL ContactLists index only' do
    check_routing( 'get', '/cdl', 'contact_lists', 'index' )
  end

  test 'special routes: SFA AbbrSearch' do
    check_routing( 'get', '/sfa', 'abbr_search', 'index' )
  end

  test 'special routes: SCS SCodeSearch' do
    check_routing( 'get', '/scs', 's_code_search', 'index' )
  end

  test 'special routes: ACS ACodeSearch' do
    check_routing( 'get', '/acs', 'a_code_search', 'index' )
  end

  test 'special routes: FRQ FeatureResponsibilities' do
    check_routing( 'get', '/frq', 'feature_responsibilities', 'index' )
  end

  test 'special routes: WRQ WorkflowResponsibilities' do
    check_routing( 'get', '/wrq', 'workflow_responsibilities', 'index' )
  end

  test 'special routes: Help Pages' do
    check_routing( 'get', '/help'      , 'help_pages', 'show_default' )
    check_routing( 'get', '/help/topic', 'help_pages', 'show', title: 'topic' )
  end

  test 'special routes: HLD Add Holidays' do
    check_routing( 'get', '/hld/1/new', 'holidays', 'add', id: '1' )
  end

  test 'special routes: Profile' do
    check_routing( 'get', '/profile'     , 'profiles', 'show'   )
    check_routing( 'get', '/profile/edit', 'profiles', 'edit'   )
    check_routing( 'put', '/profile'     , 'profiles', 'update' )
  end

  test 'special routes: DPR DsrProgressRates' do # only: index, show, edit, update
    check_routing( 'get', '/dpr'       , 'dsr_progress_rates', 'index'           )
    check_routing( 'get', '/dpr/1'     , 'dsr_progress_rates', 'show',   id: '1' )
    check_routing( 'get', '/dpr/1/edit', 'dsr_progress_rates', 'edit',   id: '1' )
    check_routing( 'put', '/dpr/1'     , 'dsr_progress_rates', 'update', id: '1' )
  end

  test 'special routes: MCR My Change Requests' do
    check_routing( 'get', '/mcr/new/1'  , 'my_change_requests', 'new', feature_id: '1' )
    check_routing( 'get', '/mcr/new/1/2', 'my_change_requests', 'new', feature_id: '1', detail: '2' )
  end

  test 'special routes: RSR RfcStatusRecords' do
    check_routing( 'get', '/rsr/info'   , 'rfc_status_records', 'info_workflow' )
    check_routing( 'get', '/rsr/stats'  , 'rfc_status_records', 'stats'         )
  end

  test 'special routes: DSR DsrStatusRecords' do
    check_routing( 'get', '/dsr/info'    , 'dsr_status_records', 'info_workflow' )
    check_routing( 'get', '/dsr/stats'   , 'dsr_status_records', 'stats' )
    check_routing( 'get', '/dsr/1/stats' , 'dsr_status_records', 'stats', id: '1' )
    check_routing( 'get', '/dsr/update'  , 'dsr_status_records', 'update_b_all' )
    check_routing( 'get', '/dsr/1/update', 'dsr_status_records', 'update_b_one', id: '1' )
  end

  test 'special routes: ISR Agreements' do
    check_routing( 'get', '/isa'         , 'isr_agreements', 'index' )
    check_routing( 'get', '/isa/stats'   , 'isr_agreements', 'show_stats' )
  end
 
  test 'special routes: ISR Interfaces' do
    check_routing( 'get', '/isr/info'    , 'isr_interfaces', 'info_workflow' )
    check_routing( 'get', '/isr/1/all'   , 'isr_interfaces', 'show_all'   , id: '1' )
    check_routing( 'get', '/isr/ia/1'    , 'isr_interfaces', 'show_ia'    , id: '1' )
    check_routing( 'get', '/isr/ia/1/all', 'isr_interfaces', 'show_ia_all', id: '1' )
    check_routing( 'get', '/isr/ia/1/icf', 'isr_interfaces', 'show_ia_icf', id: '1' )
    check_routing( 'get', '/isr/ia/1/edit','isr_interfaces', 'edit_ia'    , id: '1' )
    check_routing( 'get', '/isr/ia/1/new', 'isr_interfaces', 'new_wf'     , id: '1' )
    check_routing( 'get', '/isr/1/new'   , 'isr_interfaces', 'new_ia'     , id: '1' )
    check_routing( 'post','/isr/ia/1'    , 'isr_interfaces', 'create_ia'  , id: '1' )
    check_routing( 'put',   '/isr/ia/1'  , 'isr_interfaces', 'update_ia'  , id: '1' )
    check_routing( 'patch', '/isr/ia/1'  , 'isr_interfaces', 'update_ia'  , id: '1' )
    check_routing( 'delete','/isr/ia/1'  , 'isr_interfaces', 'destroy_ia' , id: '1' )
  end    

  test 'special routes: PCS PcpSubjects' do
    check_routing( 'get', '/pcs/1/release' , 'pcp_subjects', 'update_release', id: '1' )
    check_routing( 'get', '/pcs/1/history' , 'pcp_subjects', 'show_history',   id: '1' )
    check_routing( 'get', '/pcs/1/reldoc/1', 'pcp_subjects', 'show_release',   id: '1', step_no: '1' )
  end

  test 'special routes: PCI PcpItems' do
    check_routing( 'get',   'pci/1/next'   , 'pcp_items', 'show_next',      id: '1' )
    check_routing( 'get',   'pci/1/publish', 'pcp_items', 'update_publish', id: '1' )
    # PcpComments
    check_routing( 'post',  'pci/1/pco'    , 'pcp_items', 'create_comment', id: '1' )
    check_routing( 'get',   'pci/1/pco/new', 'pcp_items', 'new_comment',    id: '1' )
    check_routing( 'get',   'pco/1/edit'   , 'pcp_items', 'edit_comment',   id: '1' )
    check_routing( 'put',   'pco/1'        , 'pcp_items', 'update_comment', id: '1' )
    check_routing( 'patch', 'pco/1'        , 'pcp_items', 'update_comment', id: '1' )
  end

  test 'special routes: PCA PcpAllSubjects' do
    check_routing( 'get', 'pca/stats',  'pcp_all_subjects', 'stats' )
  end

  test 'special routes for SIR (shallow nested) - SIR Items' do
    check_routing( 'get', 'sil/1/sii',     'sir_items', 'index',  sir_log_id: '1' )
    check_routing( 'post','sil/1/sii',     'sir_items', 'create', sir_log_id: '1' )
    check_routing( 'get', 'sil/1/sii/new', 'sir_items', 'new',    sir_log_id: '1' )
    #
    check_routing( 'get',   'sii/1/all',  'sir_items', 'show_all', id: '1' )
    check_routing( 'get',   'sii/1/edit', 'sir_items', 'edit',     id: '1' )
    check_routing( 'get',   'sii/1',      'sir_items', 'show',     id: '1' )
    check_routing( 'patch', 'sii/1',      'sir_items', 'update',   id: '1' )
    check_routing( 'put',   'sii/1',      'sir_items', 'update',   id: '1' )
    check_routing( 'delete','sii/1',      'sir_items', 'destroy',  id: '1' )
  end

  test 'special routes for SIR (shallow nested) - SIR Entries' do
    check_routing( 'post',  'sii/1/sie',     'sir_entries', 'create', sir_item_id: '1' )
    check_routing( 'get',   'sii/1/sie/new', 'sir_entries', 'new',    sir_item_id: '1' )
    #
    check_routing( 'get',   'sie/1/edit', 'sir_entries', 'edit',    id: '1' )
    check_routing( 'get',   'sie/1',      'sir_entries', 'show',    id: '1' )
    check_routing( 'patch', 'sie/1',      'sir_entries', 'update',  id: '1' )
    check_routing( 'put',   'sie/1',      'sir_entries', 'update',  id: '1' )
    check_routing( 'delete','sie/1',      'sir_entries', 'destroy', id: '1' )
  end

  def check_routing( method, path, controller, action, ids = {})
    assert_routing({ method: method, path: path },{ controller: controller, action: action }.merge( ids ))
    assert @@action_prefix.include?( action[/[a-z]+/]),"action #{action} has no permitted prefix"
  end

end
