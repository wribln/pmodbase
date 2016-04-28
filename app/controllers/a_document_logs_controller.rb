class ADocumentLogsController < ApplicationController
  require 'csv'
  include ControllerMethods
  initialize_feature FEATURE_ID_A_DOCUMENT_LOG, FEATURE_ACCESS_VIEW
  before_action :set_a_document_log, only: [ :show, :edit, :update, :destroy ]

  # GET /adl

  def index
    @filter_fields = filter_params
    respond_to do |format|
      format.html do
        @a_document_logs = ADocumentLog.reverse.filter( @filter_fields ).paginate( page: params[ :page ])
      end
      format.xls do
        @a_document_logs = ADocumentLog.inorder.filter( @filter_fields )
        set_header( :xls, 'siemena_document_log.csv' )
      end
    end
  end

  # GET /adl/1

  def show
  end

  # GET /adl/new

  def new
    @a_document_log = ADocumentLog.new
    @a_document_log.account = current_user
  end

  # GET /adls/1/edit

  def edit
  end

  # POST /adl

  def create
    @a_document_log = ADocumentLog.new( a_document_log_params )
    @a_document_log.account_id = current_user.id
    respond_to do |format|
      if @a_document_log.save
        @a_document_log.update_attribute( :doc_id, '' )
        format.html { redirect_to @a_document_log, notice: t( 'a_document_logs.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /adl/1

  def update
    respond_to do |format|
      if @a_document_log.update(a_document_log_params)
        format.html { redirect_to @a_document_log, notice: t( 'a_document_logs.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /adl/1

  def destroy
    @a_document_log.destroy
    respond_to do |format|
      format.html { redirect_to a_document_logs_url, notice: t( 'a_document_logs.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_a_document_log
      @a_document_log = ADocumentLog.find( params[ :id ])
      @a34_code = @a_document_log.a3_code + '-' + @a_document_log.a4_code
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def a_document_log_params
      if params.has_key?( :a34_code ) then
        a34a = params.delete( :a34_code ).split( '-', 2 )
        a34m = { a3_code: a34a.first, a4_code: a34a.last }
      else
        a34m = nil
      end
      params.require( :a_document_log ).merge( a34m ).permit( 
        :a1_code, :a2_code, :a3_code, :a4_code, :a5_code, :a6_code, :a7_code, :a8_code, :title )
    end

    def filter_params
      params.slice( :ff_srec, :ff_adic, :ff_titl ).clean_up
    end

end
