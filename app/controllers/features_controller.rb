class FeaturesController < ApplicationController
  initialize_feature FEATURE_ID_FEATURE_ITEMS, FEATURE_ACCESS_SOME
  before_action :set_feature, only: [:show, :edit, :update, :destroy]
  before_action :set_selections, only: [ :new, :edit, :create, :update ]

  # GET /features

  def index
    @features = Feature.all.order( :feature_category_id, :seqno )
  end

  # GET /features/1

  def show
  end

  # GET /features/new

  def new
    @feature = Feature.new
  end

  # GET /features/1/edit

  def edit
  end

  # POST /features

  def create
    @feature = Feature.new( feature_params )
    respond_to do |format|
      if @feature.save
        format.html { redirect_to @feature, notice: t( 'features.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /features/1

  def update
    respond_to do |format|
      if @feature.update( feature_params )
        format.html { redirect_to @feature, notice: t( 'features.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /features/1

  def destroy
    @feature.destroy
    respond_to do |format|
      format.html { redirect_to features_url, notice: t( 'features.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_feature
      @feature = Feature.find( params[ :id ])
    end

    def set_selections
      @feature_categories = FeatureCategory.order( :seqno ).all
    end

    # Never trust parameters from the scary internet, only allow the white list through

    def feature_params
      if action_name == 'create' then
        params.require( :feature ).permit( :label, :seqno, :feature_category_id,
                                           :code, :access_level, :control_level )
      else
        params.require( :feature ).permit( :label, :seqno, :feature_category_id )
      end
    end
    
end
