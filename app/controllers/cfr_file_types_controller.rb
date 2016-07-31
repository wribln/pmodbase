class CfrFileTypesController < ApplicationController

  initialize_feature FEATURE_ID_CFR_FILE_TYPES, FEATURE_ACCESS_SOME 
  before_action :set_cfr_file_type, only: [ :show, :edit, :update, :destroy ]

  # GET /cft

  def index
    @cfr_file_types = CfrFileType.all
  end

  # GET /cft/1

  def show
  end

  # GET /cft/new

  def new
    @cfr_file_type = CfrFileType.new
  end

  # GET /cft/1/edit

  def edit
  end

  # POST /cft

  def create
    @cfr_file_type = CfrFileType.new( cfr_file_type_params )
    respond_to do |format|
      if @cfr_file_type.save
        format.html { redirect_to @cfr_file_type, notice: I18n.t( 'cfr_file_types.msg.create_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /cft/1

  def update
    respond_to do |format|
      if @cfr_file_type.update(cfr_file_type_params)
        format.html { redirect_to @cfr_file_type, notice: I18n.t( 'cfr_file_types.msg.update_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /cft/1

  def destroy
    @cfr_file_type.destroy
    respond_to do |format|
      format.html { redirect_to cfr_file_types_url, notice: I18n.t( 'cfr_file_types.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions

    def set_cfr_file_type
      @cfr_file_type = CfrFileType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through

    def cfr_file_type_params
      params.require( :cfr_file_type ).permit( :extensions, :label )
    end
end
