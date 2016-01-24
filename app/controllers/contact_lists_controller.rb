class ContactListsController < ApplicationController
  require 'csv'
  include ControllerMethods
  
  initialize_feature FEATURE_ID_CONTACT_LISTS, FEATURE_ACCESS_USER

  # GET /contact_lists
  #                    where( people: { involved: true }).
  
  def index
    @filter_fields = params.slice( :ff_group, :ff_name, :ff_resp, :ff_email, :ff_dept, :ff_addr ).clean_up
    @contact_list = Responsibility.
                    includes( :group, person: [{ contact_infos: :address }] ).
                    order( :group_id, :seqno ).filter( @filter_fields ).paginate( page: params[ :page ])
    respond_to do |format|
      format.html { @contact_list = @contact_list.paginate( page: params[ :page ])}
      format.xls  { set_header( :xls, 'contact_list.csv' )}
    end
  end

  # GET /contact_lists/info - for a short list with accounts -
  # for situations where a selection by account_id is required (e.g. TiaMember)

  def info
    @accounts = Account.where( active: true ).includes( :person )
  end

  def show
    @person = Person.find( params[ :id ])
  end

end
