class DsrProgressRatesController < ApplicationController

  initialize_feature FEATURE_ID_DSR_PROGRESS_RATES, FEATURE_ACCESS_VIEW

  before_action :set_dsr_progress_rate, only: [ :show, :edit, :update ]

  # GET /dprs

  def index
    @dsr_progress_rates = DsrProgressRate.all
  end

  # GET /dprs/1

  def show
  end

  # PATCH/PUT /dprs/1

  def update
    respond_to do |format|
      if @dsr_progress_rate.update( dsr_progress_rate_params )
        format.html { redirect_to @dsr_progress_rate, notice: t('dsr_progress_rates.msg.edit_ok') }
      else
        format.html { render :edit }
      end
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_dsr_progress_rate
      @dsr_progress_rate = DsrProgressRate.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def dsr_progress_rate_params
      params.require( :dsr_progress_rate ).permit( :document_progress, :prepare_progress, :approve_progress )
    end

end
