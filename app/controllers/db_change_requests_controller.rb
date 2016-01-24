# "DbChangeRequests" handles all change requests for the system to
# be managed by the respective responsible persons.
# See "MyChangeRequests" for the controller of all change requests
# created by the current user.

class DbChangeRequestsController < ApplicationController
  initialize_feature FEATURE_ID_DB_CHANGE_REQUESTS, FEATURE_ACCESS_SOME
  before_action :set_db_change_request, only: [:show, :edit, :update, :destroy]

  # GET /db_change_requests - show most recent 20 records

  def index
    @dbcrs = DbChangeRequest.last( 20 )
  end

  # GET /db_change_requests/1

  def show
  end

  # GET /db_change_requests/new

  def new
    @dbcr = DbChangeRequest.new
  end

  # GET /db_change_requests/1/edit

  def edit
  end

  # POST /db_change_requests

  def create
    @dbcr = DbChangeRequest.new( db_change_request_params )
    respond_to do |format|
      if @dbcr.save
        format.html { redirect_to @dbcr, notice: t( 'db_change_requests.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /db_change_requests/1

  def update
    respond_to do |format|
      if @dbcr.update( db_change_request_params )
        format.html { redirect_to @dbcr, notice: t( 'db_change_requests.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /db_change_requests/1

  def destroy
    @dbcr.destroy
    respond_to do |format|
      format.html { redirect_to db_change_requests_url, notice: t( 'db_change_requests.msg.delete_ok' ) }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_db_change_request
      @dbcr = DbChangeRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def db_change_request_params
      params.require( :db_change_request ).permit(
        :id,
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
