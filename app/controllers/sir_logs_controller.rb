class SirLogsController < ApplicationController
  initialize_feature FEATURE_ID_SIR_LOGS, FEATURE_ACCESS_INDEX

  before_action :set_sir_log, only: [ :show, :edit, :update, :destroy ]
  before_action :check_access, only: [ :new, :create ]

  # GET /sil

  def index
    @sir_logs = SirLog.active
  end

  # GET /sil/1

  def show
  end

  # GET /sil

  def new
    @sir_log = SirLog.new
  end

  # GET /sil/1/edit

  def edit
  end

  # POST /sil

  def create
    @sir_log = SirLog.new( sir_log_params )
    respond_to do |format|
      if @sir_log.save
        format.html { redirect_to @sir_log, notice: I18n.t( 'sir_logs.msg.create_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /sil

  def update
    respond_to do |format|
      params[ :sir_log ][ :sir_members_attributes ].try( :delete, 'template' )
      @sir_log.assign_attributes( sir_log_params ) unless sir_log_params.empty?
      if @sir_log.save
        format.html { redirect_to @sir_log, notice: I18n.t( 'sir_logs.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /sil/1

  def destroy
    @sir_log.destroy
    respond_to do |format|
      format.html { redirect_to sir_logs_url, notice: I18n.t( 'sir_logs.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
  
    def set_sir_log
      @sir_log = SirLog.find( params[ :id ])
      check_access
    end

    # only owner or deputy may access this information

    def check_access
      render_no_permission unless @sir_log.user_is_owner_or_deputy?( current_user.id )
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def sir_log_params
      params.require( :sir_log ).permit(
        :code, :label, :owner_account_id, :deputy_account_id, :archived,
        sir_members_attributes: 
          [ :id, :_destroy, :account_id, :to_access, :to_update ])
    end

end
