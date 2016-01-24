class FeatureCategoriesController < ApplicationController
  initialize_feature FEATURE_ID_FEATURE_CATEGORIES, FEATURE_ACCESS_SOME
  before_action :set_feature_category, only: [:show, :edit, :update, :destroy]

  # GET /feature_categories

  def index
    @feature_categories = FeatureCategory.all
  end

  # GET /feature_categories/1

  def show
  end

  # GET /feature_categories/new

  def new
    @feature_category = FeatureCategory.new
  end

  # GET /feature_categories/1/edit

  def edit
  end

  # POST /feature_categories

  def create
    @feature_category = FeatureCategory.new( feature_category_params )

    respond_to do |format|
      if @feature_category.save
        format.html { redirect_to @feature_category, notice: t( 'feature_categories.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /feature_categories/1

  def update
    respond_to do |format|
      if @feature_category.update( feature_category_params )
        format.html { redirect_to @feature_category, notice: t( 'feature_categories.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /feature_categories/1

  def destroy
    @feature_category.destroy
    respond_to do |format|
      format.html { redirect_to feature_categories_url, notice: t( 'feature_categories.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_feature_category
      @feature_category = FeatureCategory.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def feature_category_params
      params.require( :feature_category ).permit( :id, :label, :seqno )
    end

end