class OrlCategoriesController < ApplicationController
  before_action :set_orl_category, only: [:show, :edit, :update, :destroy]

  initialize_feature FEATURE_ID_ORL_CATEGORIES, FEATURE_ACCESS_SOME, FEATURE_CONTROL_CUG

  # GET /otp

  def index
    @orl_categories = OrlCategory.all
  end

  # GET /otp/1

  def show
  end

  # GET /otp/new

  def new
    @orl_category = OrlCategory.new
    set_selections( :to_create )
  end

  # GET /otp/1/edit

  def edit
    set_selections( :to_update )
  end

  # POST /otp

  def create
    @orl_category = OrlCategory.new( orl_category_params )
    return unless has_group_access?( @orl_category )
    respond_to do |format|
      if @orl_category.save
        format.html { redirect_to @orl_category, notice: I18n.t( 'orl_categories.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /otp/1

  def update
    respond_to do |format|
      if @orl_category.update(orl_category_params)
        format.html { redirect_to @orl_category, notice: I18n.t( 'orl_categories.msg.edit_ok' )}
      else
        set_selections( :to_create )
        format.html { render :edit }
      end
    end
  end

  # DELETE /otp/1

  def destroy
    @orl_category.destroy
    respond_to do |format|
      format.html { redirect_to orl_categories_url, notice: I18n.t( 'orl_categories.msg.delete_ok' )}
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_orl_category
      @orl_category = OrlCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def orl_category_params
      params.require( :orl_category ).permit( :o_group_id, :r_group_id, :label )
    end

    def set_selections( action )
      pg = current_user.permitted_groups( FEATURE_ID_ORL_CATEGORIES, action, :id )
      @r_group_selection = Group.active_only.participants_only.permitted_groups( pg ).all.collect{ |g| [ g.code_and_label, g.id ]}
    end

end
