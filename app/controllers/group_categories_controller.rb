class GroupCategoriesController < ApplicationController
  initialize_feature FEATURE_ID_GROUP_CATEGORIES, FEATURE_ACCESS_SOME
  before_action :set_group_category, only: [:show, :edit, :update, :destroy]

  # GET /group_categories

  def index
    @group_categories = GroupCategory.all
  end

  # GET /group_categories/1

  def show
  end

  # GET /group_categories/new

  def new
    @group_category = GroupCategory.new
  end

  # GET /group_categories/1/edit

  def edit
  end

  # POST /group_categories

  def create
    @group_category = GroupCategory.new(group_category_params)
    respond_to do |format|
      if @group_category.save
        format.html { redirect_to @group_category, notice: t( 'group_categories.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /group_categories/1

  def update
    respond_to do |format|
      if @group_category.update(group_category_params)
        format.html { redirect_to @group_category, notice: t( 'group_categories.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /group_categories/1

  def destroy
    @group_category.destroy
    respond_to do |format|
      format.html { redirect_to group_categories_url, notice: t( 'group_categories.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_group_category
      @group_category = GroupCategory.find( params[:id] )
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def group_category_params
      params.require( :group_category ).permit( :label, :seqno )
    end
end
