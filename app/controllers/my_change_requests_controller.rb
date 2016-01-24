# "MyChangeRequests" handles the change requests for the current user.
# See "DbChangeRequests" for the controller of all change requests (by
# the respective admin users)

class MyChangeRequestsController < ApplicationController
  initialize_feature FEATURE_ID_MY_CHANGE_REQUESTS, FEATURE_ACCESS_USER
  before_action :set_my_change_request, only: [ :show, :edit, :update, :destroy ]

  # GET /db_change_requests
  
  def index
    @dbcrs = DbChangeRequest.for_user( current_user.id ).order( id: :desc ).last( 20 )
  end

  # GET /db_change_requests/1

  def show
  end

  # called from index

  def new
    @dbcr = DbChangeRequest.new
    @dbcr.requesting_account_id = current_user.id
    @dbcr.status = 0
    @dbcr.feature_id = params[ :feature_id ].present? ? params[ :feature_id ] : FEATURE_ID_MY_CHANGE_REQUESTS
    @dbcr.detail = params[ :detail ] if params[ :detail ].present?
    @dbcr.action = :index
    @dbcr.uri = request.fullpath
  end

  # GET /db_change_requests/1/edit

  def edit
  end

  # POST /db_change_requests

  def create
    @dbcr = DbChangeRequest.new( my_change_request_params )
    respond_to do |format|
      if @dbcr.save
        format.html { redirect_to my_change_request_url( @dbcr ), notice: t( 'db_change_requests.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /db_change_requests/1

  def update
    respond_to do |format|
      if @dbcr.update( my_change_request_params )
        format.html { redirect_to my_change_request_url, notice: t( 'db_change_requests.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /db_change_requests/1

  def destroy
    @dbcr.destroy
    respond_to do |format|
      format.html { redirect_to my_change_requests_url, notice: t( 'db_change_requests.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_my_change_request
      @dbcr = DbChangeRequest.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    # Here: I need to carry over all parameters inserted when called, hence they must be
    # white-listed as well

    def my_change_request_params
      params.require( :db_change_request ).permit(
        :requesting_account_id,
        :responsible_account_id,
        :feature_id,
        :detail,
        :action,
        :status,
        :uri,
        :request_text )
    end

end
