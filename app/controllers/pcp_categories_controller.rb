class PcpCategoriesController < ApplicationController
  before_action :set_pcp_category, only: [ :show, :edit, :update, :destroy ]
  before_action :set_selections, only: [ :edit, :update, :new ]

  initialize_feature FEATURE_ID_PCP_CATEGORIES, FEATURE_ACCESS_VIEW

  # GET /orc

  def index
    @pcp_categories = PcpCategory.all
  end

  # GET /orc/1

  def show
  end

  # GET /orc/new

  def new
    @pcp_category = PcpCategory.new
  end

  # GET /orc/1/edit

  def edit
  end

  # POST /orc

  def create
    @pcp_category = PcpCategory.new( pcp_category_params )
    return unless has_group_access?( @pcp_category )
    respond_to do |format|
      if @pcp_category.save
        format.html { redirect_to @pcp_category, notice: I18n.t( 'pcp_categories.msg.new_ok' )}
      else
        set_selections
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /orc/1

  def update
    respond_to do |format|
      if @pcp_category.update(pcp_category_params)
        format.html { redirect_to @pcp_category, notice: I18n.t( 'pcp_categories.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /orc/1

  def destroy
    @pcp_category.destroy
    respond_to do |format|
      format.html { redirect_to pcp_categories_url, notice: I18n.t( 'pcp_categories.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_pcp_category
      @pcp_category = PcpCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def pcp_category_params
      params.require( :pcp_category ).permit( :label,
        :p_group_id, :p_owner_id, :p_deputy_id,
        :c_group_id, :c_owner_id, :c_deputy_id )
    end

    def set_selections
      @group_selection = Group.active_only.participants_only.collect{ |g| [ g.code_and_label, g.id ]}
    end

end
