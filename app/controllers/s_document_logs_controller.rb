class SDocumentLogsController < ApplicationController
  require 'csv'
  include ControllerMethods
  initialize_feature FEATURE_ID_S_DOCUMENT_LOG, FEATURE_ACCESS_VIEW
  before_action :set_s_document_log, only: [ :show, :edit, :update, :destroy ]

  # GET /sdl

  def index
    @filter_fields = filter_params
    respond_to do |format|
      format.html do
        @s_document_logs = SDocumentLog.revorder.filter( @filter_fields ).paginate( page: params[ :page ])
      end
      format.xls do
        @s_document_logs = SDocumentLog.inorder.filter( @filter_fields )
        set_header( :xls, 'siemens_document_log.csv' )
      end
    end
  end

  # GET /sdl/1

  def show
  end

  # GET /sdl/new

  def new
    @s_document_log = SDocumentLog.new( account: current_user )
    set_selections( :to_create )
  end

  # GET /sdls/1/edit

  def edit
    set_selections( :to_update )
  end

  # POST /sdl

  def create
    @s_document_log = SDocumentLog.new( s_document_log_params )
    return unless has_group_access?( @s_document_log.group_id )
    @s_document_log.account_id = current_user.id
    respond_to do |format|
      if @s_document_log.save
        @s_document_log.update_attribute( :doc_id, '' )
        format.html { redirect_to @s_document_log, notice: t( 's_document_logs.msg.new_ok' )}
      else
        set_selections( :to_create )
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /sdl/1

  def update
    @s_document_log.assign_attributes( s_document_log_params )
    return unless has_group_access?( @s_document_log.group_id )
    respond_to do |format|
      if @s_document_log.save
        format.html { redirect_to @s_document_log, notice: t( 's_document_logs.msg.edit_ok' )}
      else
        set_selections( :to_update )
        format.html { render :edit }
      end
    end
  end

  # DELETE /sdl/1

  def destroy
    @s_document_log.destroy
    respond_to do |format|
      format.html { redirect_to s_document_logs_url, notice: t( 's_document_logs.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_s_document_log
      @s_document_log = SDocumentLog.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def s_document_log_params
      params.require( :s_document_log ).permit( 
        :group_id, :receiver_group, :function_code, :service_code, :product_code, :location_code,
        :phase_code, :dcc_code, :revision_code, :author_date, :title )
    end

    def filter_params
      params.slice( :ff_srec, :ff_sdic, :ff_titl ).clean_up
    end

    def set_selections( action )
      pg = current_user.permitted_groups( feature_identifier, action )
      @group_selection = Group.active_only.sender_codes.permitted_groups( pg ).all.collect{ |g| [ g.code_and_label, g.id ]}
    end

end
