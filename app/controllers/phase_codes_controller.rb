class PhaseCodesController < ApplicationController
  initialize_feature FEATURE_ID_PHASE_CODES, FEATURE_ACCESS_INDEX
  before_action :set_phase_code, only: [ :show, :edit, :update, :destroy ]
  before_action :set_selections, only: [ :new, :edit, :create, :update ]

  # GET /phase_codes
  
  def index
    @phase_codes = PhaseCode.all.order( :code )
  end

  # GET /phase_codes/1
  
  def show
  end

  # GET /phase_codes/new
  
  def new
    @phase_code = PhaseCode.new
  end

  # GET /phase_codes/1/edit
  
  def edit
  end

  # POST /phase_codes
  
  def create
    @phase_code = PhaseCode.new( phase_code_params )

    respond_to do |format|
      if @phase_code.save
        format.html { redirect_to @phase_code, notice: t( 'phase_codes.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /phase_codes/1

  def update
    respond_to do |format|
      if @phase_code.update( phase_code_params )
        format.html { redirect_to @phase_code, notice: t( 'phase_codes.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /phase_codes/1

  def destroy
    @phase_code.destroy
    respond_to do |format|
      format.html { redirect_to phase_codes_url, notice: t( 'phase_codes.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_phase_code
      @phase_code = PhaseCode.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def phase_code_params
      params.require( :phase_code ).permit( :id, :code, :label, :acro, :siemens_phase_id, :level )
    end

    def set_selections
      @siemens_phases = SiemensPhase.select( :id, :code ).order( :code ).all
    end

end
