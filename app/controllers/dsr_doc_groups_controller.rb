class DsrDocGroupsController < ApplicationController
  initialize_feature FEATURE_ID_DSR_DOC_GROUPS, FEATURE_ACCESS_SOME, FEATURE_CONTROL_GRP
  before_action :set_dsr_doc_group,   only: [ :show, :edit, :update, :destroy ]

  # GET /ddgs

  def index
    @dsr_doc_groups = DsrDocGroup.all
  end

  # GET /ddgs/1

  def show
  end

  # GET /ddgs/new

  def new
    @dsr_doc_group = DsrDocGroup.new
    @dsr_groups = permitted_groups( :to_create )
  end

  # GET /ddgs/1/edit

  def edit
    @dsr_groups = permitted_groups( :to_update )
  end

  # POST /ddgs

  def create
    @dsr_doc_group = DsrDocGroup.new( dsr_doc_group_params )
    @dsr_groups = permitted_groups( :to_create )
    respond_to do |format|
      if @dsr_doc_group.save
        format.html { redirect_to @dsr_doc_group, notice: t( 'dsr_doc_groups.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /ddgs/1

  def update
    respond_to do |format|
      if @dsr_doc_group.update( dsr_doc_group_params )
        format.html { redirect_to @dsr_doc_group, notice: t( 'dsr_doc_groups.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /dsr_doc_groups/1

  def destroy
    @dsr_doc_group.destroy
    respond_to do |format|
      format.html { redirect_to dsr_doc_groups_url, notice: t( 'dsr_doc_groups.msg.delete_ok' )}
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_dsr_doc_group
      @dsr_doc_group = DsrDocGroup.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def dsr_doc_group_params
      params.require( :dsr_doc_group ).permit( :group_id, :code, :title )
    end

    # Prepare a list of permitted groups

    def permitted_groups( action )
      pg = current_user.permitted_groups( feature_identifier, action )
      Group.permitted_groups( pg ).all.collect{ |g| [ g.code_with_id, g.id ]}
    end

end
