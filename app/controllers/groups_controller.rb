class GroupsController < ApplicationController
  require 'csv'
  include ControllerMethods

  initialize_feature FEATURE_ID_GROUPS, FEATURE_ACCESS_INDEX

  before_action :set_group, only: [ :show, :edit, :update, :destroy ]
  before_action :set_selections, only: [ :edit, :new, :create, :update ]

  # GET /groups

  def index
    @groups = Group.includes( :group_category ).reorder( "group_categories.seqno", :seqno )
    respond_to do |format|
      format.html
      format.xls { set_header( :xls, 'groups.csv' )}
    end
  end

  # GET /groups/1

  def show
  end

  # GET /groups/new

  def new
    @group = Group.new
  end

  # GET /groups/1/edit

  def edit
  end

  # POST /groups

  def create
    @group = Group.new( group_params )
    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: t( 'groups.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /groups/1

  def update
    respond_to do |format|
      if @group.update( group_params )
        format.html { redirect_to @group, notice: t( 'groups.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /groups/1

  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: t( 'groups.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    
    def set_group
      @group = Group.find( params[ :id ])
    end

    def set_selections
      @group_categories = GroupCategory.order( :seqno ).all
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def group_params
      params.require( :group ).permit( :id, :code, :label, :notes, :seqno, :group_category_id )
    end

end
