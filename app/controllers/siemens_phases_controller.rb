class SiemensPhasesController < ApplicationController
  initialize_feature FEATURE_ID_SIEMENS_PHASES, FEATURE_ACCESS_SOME
  before_action :set_siemens_phase, only: [:show, :edit, :update, :destroy]

  # GET /siemens_phases
  
  def index
    @siemens_phases = SiemensPhase.all.order( :code )
  end

  # GET /siemens_phases/1
  
  def show
  end

  # GET /siemens_phases/new

  def new
    @siemens_phase = SiemensPhase.new
  end

  # GET /siemens_phases/1/edit

  def edit
  end

  # POST /siemens_phases
  
  def create
    @siemens_phase = SiemensPhase.new( siemens_phase_params )

    respond_to do |format|
      if @siemens_phase.save
        format.html { redirect_to @siemens_phase, notice: t( 'siemens_phases.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /siemens_phases/1
  
  def update
    respond_to do |format|
      if @siemens_phase.update(siemens_phase_params)
        format.html { redirect_to @siemens_phase, notice: t( 'siemens_phases.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /siemens_phases/1

  def destroy
    @siemens_phase.destroy
    respond_to do |format|
      format.html { redirect_to siemens_phases_url, notice: t( 'siemens_phases.msg.delete_ok') }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_siemens_phase
      @siemens_phase = SiemensPhase.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def siemens_phase_params
      params.require( :siemens_phase ).permit( :id, :code, :label_p, :label_m )
    end

end
