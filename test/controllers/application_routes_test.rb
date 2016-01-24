require 'test_helper'
class ApplicationRoutesTest < ActionController::TestCase

  # test all standard resources:

  @my_resources = [
    %w( AAA Abbreviations ),
    %w( ANP Accounts ),
    %w( ADT Addresses ),
    %w( CCI ContactInfos ),
    %w( CNC CountryNames ),
    %w( ACR DBChangeRequests ),
    %w( DSR DsrStatusRecords ),
    %w( DDG DsrDocGroups ),
    %w( DSB DsrSubmissions ),
    %w( FIT Features ),
    %w( FCT FeatureCategories ),
    %w( GLO GlossaryItems ),
    %w( GRP Groups ),
    %w( GCT GroupCategories ),
    %w( HLD Holidays ),
    %w( APT People ),
    %w( PPC PhaseCodes ),
    %w( RNC RegionNames ),
    %w( RPP Responsibilities ),
    %w( REF References ),
    %w( RCD RfcDocuments ),
    %w( RSR RfcStatusRecords ),
    %w( SPC SiemensPhases ),
    %w( SSO StandardsBodies ),
    %w( SGP SubmissionGroups ),
    %w( ATL AllTiaLists ),
    %w( MTL MyTiaLists ),
    %w( MTI MyTiaItems ),
    %w( MCR MyChangeRequests ),
    %w( UNC UnitNames ),
    %w( WLK WebLinks )
    ]

  @my_resources.each do |r|
    test "standard resource routing #{ r[0] } to #{ r[1] }" do

      p = "/#{ r[0].downcase.pluralize }"
      c = r[1].underscore

      assert_routing({ method: 'get',    path: "#{ p }"        }, { controller: c, action: 'index'   })
      assert_routing({ method: 'get',    path: "#{ p }/new"    }, { controller: c, action: 'new'     })
      assert_routing({ method: 'post',   path: "#{ p }"        }, { controller: c, action: 'create'  })
      assert_routing({ method: 'get',    path: "#{ p }/1"      }, { controller: c, action: 'show'    , id: '1' })
      assert_routing({ method: 'get',    path: "#{ p }/1/edit" }, { controller: c, action: 'edit'    , id: '1' })
      assert_routing({ method: 'put',    path: "#{ p }/1"      }, { controller: c, action: 'update'  , id: '1' })
      assert_routing({ method: 'delete', path: "#{ p }/1"      }, { controller: c, action: 'destroy' , id: '1' })
    end
  end

  test "mtls nested routing" do
    [ %w( otis our_tia_items ), %w( otms our_tia_members )].each do |r|
      assert_routing({ method: 'get',    path: "mtls/1/#{ r[ 0 ] }"     }, { controller: r[ 1 ], action: 'index',  my_tia_list_id: '1' })
      assert_routing({ method: 'post',   path: "mtls/1/#{ r[ 0 ] }"     }, { controller: r[ 1 ], action: 'create', my_tia_list_id: '1' })
      assert_routing({ method: 'get',    path: "mtls/1/#{ r[ 0 ] }/new" }, { controller: r[ 1 ], action: 'new',    my_tia_list_id: '1' })
  
      assert_routing({ method: 'get',    path: "#{ r[ 0 ]}/1"           }, { controller: r[ 1 ], action: 'show',    id: '1' })
      assert_routing({ method: 'get',    path: "#{ r[ 0 ]}/1/edit"      }, { controller: r[ 1 ], action: 'edit',    id: '1' })
      assert_routing({ method: 'put',    path: "#{ r[ 0 ]}/1"           }, { controller: r[ 1 ], action: 'update',  id: '1' })
      assert_routing({ method: 'delete', path: "#{ r[ 0 ]}/1"           }, { controller: r[ 1 ], action: 'destroy', id: '1' })
    end
  end

  test "special routes: tia_items" do
    [ %w( mtis my_tia_items ), %w( otis our_tia_items )].each do |r|
      assert_routing({ method: 'get', path: "/#{ r[ 0 ]}/1/info" }, { controller: r[ 1 ], action: 'info', id: '1' })
    end
  end

  test "special routes: home/root" do
    assert_routing({ method: 'get',  path: '/'             }, { controller: 'home', action: 'index'   })
    assert_routing({ method: 'post', path: '/home/signon'  }, { controller: 'home', action: 'signon'  })
    assert_routing({ method: 'get',  path: '/home/signoff' }, { controller: 'home', action: 'signoff' })
  end

  test "special routes: CDL ContactLists index only" do
    assert_routing({ method: 'get', path: '/cdls' }, { controller: 'contact_lists', action: 'index' })
  end

  test "special routes: SFA AbbrSearch" do
    assert_routing({ method: 'get', path: '/sfas' }, { controller: 'abbr_search', action: 'index' })
  end

  test "special routes: FRQ FeatureResponsibilities" do
    assert_routing({ method: 'get', path: '/frqs' }, { controller: 'feature_responsibilities', action: 'index' })
  end

  test "special routes: WRQ WorkflowResponsibilities" do
    assert_routing({ method: 'get', path: '/wrqs' }, { controller: 'workflow_responsibilities', action: 'index' })
  end

  test "special routes: Help Pages" do
    assert_routing({ method: 'get', path: '/help'       }, { controller: 'help_pages', action: 'show_default' })
    assert_routing({ method: 'get', path: '/help/topic' }, { controller: 'help_pages', action: 'show', title: 'topic' })
  end

  test "special routes: Add Holidays" do
    assert_routing({ method: 'get', path: '/hlds/1/new' }, { controller: 'holidays', action: 'add', id: '1' })
  end

  test "special routes: Profile" do
    assert_routing({ method: 'get', path: '/profile'      }, { controller: 'profiles', action: 'show'   })
    assert_routing({ method: 'get', path: '/profile/edit' }, { controller: 'profiles', action: 'edit'   })
    assert_routing({ method: 'put', path: '/profile'      }, { controller: 'profiles', action: 'update' })
  end

  test "special routes: DsrProgressRates" do # only: index, show, edit, update
    assert_routing({ method: 'get', path: '/dprs'        }, { controller: 'dsr_progress_rates', action: 'index'  })
    assert_routing({ method: 'get', path: '/dprs/1'      }, { controller: 'dsr_progress_rates', action: 'show',   id: '1' })
    assert_routing({ method: 'get', path: '/dprs/1/edit' }, { controller: 'dsr_progress_rates', action: 'edit',   id: '1' })
    assert_routing({ method: 'put', path: '/dprs/1'      }, { controller: 'dsr_progress_rates', action: 'update', id: '1' })
  end

  test "special routes: My Change Requests" do
    assert_routing({ method: 'get', path: '/mcrs/new/1'   }, { controller: 'my_change_requests', action: 'new', feature_id: '1' })
    assert_routing({ method: 'get', path: '/mcrs/new/1/2' }, { controller: 'my_change_requests', action: 'new', feature_id: '1', detail: '2' })
  end

  test "special routes: RfcStatusRecords" do
    assert_routing({ method: 'get', path: '/rsrs/info'    }, { controller: 'rfc_status_records', action: 'info'  })
    assert_routing({ method: 'get', path: '/rsrs/stats'   }, { controller: 'rfc_status_records', action: 'stats' })
  end

  test "special routes: DsrStatusRecords" do
    assert_routing({ method: 'get', path: '/dsrs/info'    }, { controller: 'dsr_status_records', action: 'info'  })
    assert_routing({ method: 'get', path: '/dsrs/stats'   }, { controller: 'dsr_status_records', action: 'stats' })
    assert_routing({ method: 'get', path: '/dsrs/1/stats' }, { controller: 'dsr_status_records', action: 'stats', id: '1'})
    assert_routing({ method: 'get', path: '/dsrs/update'  }, { controller: 'dsr_status_records', action: 'update_b_all' })
    assert_routing({ method: 'get', path: '/dsrs/1/update'}, { controller: 'dsr_status_records', action: 'update_b_one', id: '1' })
  end

end
