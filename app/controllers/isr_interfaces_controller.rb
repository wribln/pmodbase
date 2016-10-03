class IsrInterfacesController < ApplicationController

  initialize_feature FEATURE_ID_ISR_INTERFACES, FEATURE_ACCESS_INDEX, FEATURE_CONTROL_GRPWF, 1

  #before_action :set_general_workflow
  before_action :set_isr_interface, only: [:show, :edit, :update, :destroy]

  # GET /isr

  def index
    @isr_interfaces = IsrInterface.all
  end

  # GET /isr/1

  def show
  end

  # GET /isr

  def new
    @isr_interface = IsrInterface.new
  end

  # GET /isr/1/edit

  def edit
  end

  # POST /isr

  def create
    @isr_interface = IsrInterface.new( isr_interface_params )
    respond_to do |format|
      if @isr_interface.save
        format.html { redirect_to @isr_interface, notice: 'Ifr interface was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /isr/1

  def update
    respond_to do |format|
      if @isr_interface.update(isr_interface_params)
        format.html { redirect_to @isr_interface, notice: 'Ifr interface was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /isr/1

  def destroy
    @isr_interface.destroy
    respond_to do |format|
      format.html { redirect_to isr_interfaces_url, notice: 'Ifr interface was successfully destroyed.' }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_isr_interface
      @isr_interface = IsrInterface.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def isr_interface_params
      params.require( :isr_interface ).permit(
        :interface_id, :l_group_id, :p_group_id, :title, :desc, 
        :current_status, :current_task, :cfr_record_id, :safety_related )
    end

end
