class SubmissionGroupsController < ApplicationController
  initialize_feature FEATURE_ID_SUBMISSION_GROUPS, FEATURE_ACCESS_INDEX
  before_action :set_submission_group, only: [:show, :edit, :update, :destroy]

  # GET /sgps

  def index
    @submission_groups = SubmissionGroup.all
  end

  # GET /sgps/1

  def show
  end

  # GET /sgps/new

  def new
    @submission_group = SubmissionGroup.new
  end

  # GET /sgps/1/edit

  def edit
  end

  # POST /sgps
  def create
    @submission_group = SubmissionGroup.new( submission_group_params )
    respond_to do |format| 
      if @submission_group.save
        format.html { redirect_to @submission_group, notice: t( 'submission_groups.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /sgps/1
  
  def update
    respond_to do |format|
      if @submission_group.update( submission_group_params )
        format.html { redirect_to @submission_group, notice: t( 'submission_groups.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /submissions/1

  def destroy
    @submission_group.destroy
    respond_to do |format|
      format.html { redirect_to submission_groups_url, notice: t( 'submission_groups.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_submission_group
      @submission_group = SubmissionGroup.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def submission_group_params
      params.require( :submission_group ).permit( :code, :label, :seqno )
    end
end
