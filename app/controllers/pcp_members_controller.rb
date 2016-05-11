class PcpMembersController < ApplicationController
  include ControllerMethods

  initialize_feature FEATURE_ID_PCP_MEMBERS, FEATURE_ACCESS_USER + FEATURE_ACCESS_NDA, FEATURE_CONTROL_CUG

  before_action :set_pcp_member,  only: [ :show, :edit, :update, :destroy ]
  before_action :set_pcp_subject
  before_action :set_breadcrumb

  # GET /pcs/:pcp_subject_id/pcm

  def index
    case @viewing_group
    when 0
      render_no_permission
    when 1 
      @pcp_members = @pcp_subject.pcp_members.presenting_group
    when 2
      @pcp_members = @pcp_subject.pcp_members.commenting_group
    when 3
      @pcp_members = @pcp_subject.pcp_members
    end
  end

  # GET /pcs/:pcp_subject_id/pcm/1

  def show
  end

  # GET /pcs/:pcp_subject_id/pcm/new

  def new
    @pcp_member = @pcp_subject.pcp_members.new
  end

  # GET /pcs/:pcp_subject_id/pcm/1/edit

  def edit
  end

  # POST /pcs/:pcp_subject_id/pcm

  def create
    @pcp_member = @pcp_subject.pcp_members.new( pcp_member_params )
    respond_to do |format|
      if @pcp_member.save
        format.html { redirect_to pcp_subject_pcp_member_path( @pcp_subject, @pcp_member ), notice: I18n.t( 'pcp_members.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /pcs/:pcp_subject_id/pcm/1

  def update
    respond_to do |format|
      if @pcp_member.update( pcp_member_params )
        format.html { redirect_to pcp_subject_pcp_member_path( @pcp_subject, @pcp_member ), notice: I18n.t( 'pcp_members.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /pcm/1

  def destroy
    @pcp_member.destroy
    respond_to do |format|
      format.html { redirect_to pcp_subject_pcp_members_path( @pcp_subject ), notice: I18n.t( 'pcp_members.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_pcp_member
      @pcp_member = PcpMember.find( params[ :id ])
    end

    def set_pcp_subject
      @pcp_subject = PcpSubject.find( params[ :pcp_subject_id ])
      @viewing_group = @pcp_subject.viewing_group_map( current_user.id )      
    end

   # Never trust parameters from the scary internet, only allow the white list through.

    def pcp_member_params
      params.require( :pcp_member ).permit( :account_id, :pcp_group, :to_access, :to_update )
    end

    # fix breadcrumb to show parent

    def set_breadcrumb
      parent_breadcrumb( :pcp_subjects, pcp_subjects_path )
      set_breadcrumb_path( pcp_subject_pcp_members_path( params[ :pcp_subject_id ]))
    end

end
