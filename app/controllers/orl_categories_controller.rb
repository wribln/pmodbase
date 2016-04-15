class OrlCategoriesController < ApplicationController
  before_action :set_orl_category, only: [ :show, :edit, :update, :destroy ]
  before_action :set_selections, only: [ :edit, :update, :new ]

  initialize_feature FEATURE_ID_ORL_CATEGORIES, FEATURE_ACCESS_VIEW

  # GET /orc

  def index
    @orl_categories = OrlCategory.all
  end

  # GET /orc/1

  def show
  end

  # GET /orc/new

  def new
    @orl_category = OrlCategory.new
  end

  # GET /orc/1/edit

  def edit
  end

  # POST /orc

  def create
    @orl_category = OrlCategory.new( orl_category_params )
    return unless has_group_access?( @orl_category )
    respond_to do |format|
      if @orl_category.save
        format.html { redirect_to @orl_category, notice: I18n.t( 'orl_categories.msg.new_ok' )}
      else
        set_selections
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /orc/1

  def update
    respond_to do |format|
      if @orl_category.update(orl_category_params)
        format.html { redirect_to @orl_category, notice: I18n.t( 'orl_categories.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /orc/1

  def destroy
    @orl_category.destroy
    respond_to do |format|
      format.html { redirect_to orl_categories_url, notice: I18n.t( 'orl_categories.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_orl_category
      @orl_category = OrlCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def orl_category_params
      params.require( :orl_category ).permit( :label,
        :o_group_id, :o_owner_id, :o_deputy_id,
        :r_group_id, :r_owner_id, :r_deputy_id )
    end

    def set_selections
      @group_selection = Group.active_only.participants_only.collect{ |g| [ g.code_and_label, g.id ]}
    end

end
