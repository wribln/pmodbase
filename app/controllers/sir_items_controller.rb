class SirItemsController < ApplicationController
#  initialize_feature FEATURE_ID_SIR_ITEMS, FEATURE_ACCESS_INDEX, FEATURE_CONTROL_GRP
  initialize_feature FEATURE_ID_SIR_ITEMS, FEATURE_ACCESS_VIEW, FEATURE_CONTROL_GRP

  before_action :set_sir_log,  only: [ :index, :new ]
  before_action :set_sir_item, only: [ :show, :show_all, :edit, :update, :destroy ]

  # GET /sil/1/sii
 
  def index
    @sir_items = @sir_log.sir_items
  end

  # GET /sii/1
 
  def show
    @sir_entries = SirEntry.all
  end

  # GET /sii/1/all

  def show_all
  end

  # GET /sil/1/sii/new

  def new
    @sir_item = SirItem.new
  end

  # GET /sii/1/edit

  def edit
  end

  # POST /sii
 
  def create
    @sir_item = SirItem.new( sir_item_params )
    respond_to do |format|
      if @sir_item.save
        format.html { redirect_to @sir_item, notice: I18n.t( 'sir_items.msg.create_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /sii/1
 
  def update
    respond_to do |format|
      if @sir_item.update(sir_item_params)
        format.html { redirect_to @sir_item, notice: I18n.t( 'sir_items.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /sii/1
 
  def destroy
    @sir_item.destroy
    respond_to do |format|
      format.html { redirect_to sir_items_url, notice: I18n.t( 'sir_items.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_sir_log
      @sir_log = SirLog.find( params[ :sir_log_id ])
    end

    def set_sir_item
      @sir_item = SirItem.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def sir_item_params
      params.require( :sir_item ).permit(
        :group_id, :reference, :cfr_record_id, :label, :status,
        :category, :phase_code_id, :archived, :description )
    end
end
