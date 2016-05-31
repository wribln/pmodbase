# This controller handles all PCP Subjects assigned to a specific person,
# either as owner or deputy (for the Presenting or the Commenting Group),
# or as member of the PCP Subject. Users need access to this feature in
# order to be able to access any action therein.

class PcpSubjectsController < ApplicationController

  before_action :set_pcp_subject,  only: [ :show, :edit, :info_history, :update, :destroy, :update_release, :show_release ]
  before_action :set_valid_params, only: [ :edit, :new, :update, :create ]
  before_action :get_item_stats, only: [ :edit, :show, :update_release ]

  initialize_feature FEATURE_ID_MY_PCP_SUBJECTS, FEATURE_ACCESS_SOME, FEATURE_CONTROL_CUG

# GET /ors

  def index
    @filter_fields = filter_params
    @filter_groups = get_groups_for_select
    @pcp_subjects = PcpSubject.filter( @filter_fields ).all_active.all_permitted( current_user ).includes( :pcp_steps ).paginate( page: params[ :page ])
  end

  # GET /pcs/1

  def show
    render_no_permission unless permission_to_view?
  end

  # GET /pcs/1/info - history

  def info_history
    render_no_permission unless permission_to_view?
  end

  # GET /pcs/1/reldoc/1

  def show_release
    unless permission_to_view?
      render_no_permission
      return
    end
    @pcp_curr_step = @pcp_subject.pcp_steps.released.where( step_no: params[ :step_no ]).first
    if @pcp_curr_step then
      @pcp_items = PcpItem.released_until( @pcp_subject, @pcp_curr_step.step_no ).includes( :pcp_comments, :pcp_step )
      render :reldoc, layout: 'plain_print'
    else
      render_no_resource
    end
  end

  # GET /pcs/new

  def new
    @pcp_subject = PcpSubject.new
    @pcp_categories = permitted_categories
  end

  # GET /pcs/1/edit

  def edit
    unless permission_to_modify?
      render_no_permission
      return
    end
    @pcp_categories = permitted_categories
    @pcp_groups = get_groups_for_select
  end

  # POST /pcs

  def create
    @pcp_subject = PcpSubject.new( pcp_subject_params )
    unless @pcp_subject.permitted_to_create?( current_user )
      render_no_permission
      return
    end
    @pcp_subject.p_owner_id = current_user.id
    @pcp_curr_step = @pcp_subject.pcp_steps.build( step_no: 0, prev_assmt: 0 )
    # this works due to the AutosaveAssocation
    respond_to do |format|
      if @pcp_subject.save then
        format.html { redirect_to @pcp_subject, notice: I18n.t( 'pcp_subjects.msg.new_ok' )}
      else
        @pcp_categories = permitted_categories
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /pcs/1
  #
  # perform update: need permission to modify;
  # check for update closed PCP Subjects is performed implicitly by
  # whitelisting only :archived flag for closed PCP Subjects

  def update
    unless permission_to_modify?
      render_no_permission
      return
    end
    respond_to do |format|
      if @pcp_subject.update( pcp_subject_params )
        format.html { redirect_to @pcp_subject, notice: I18n.t( 'pcp_subjects.msg.edit_ok' )}
      else
        @pcp_groups = get_groups_for_select
        @pcp_categories = permitted_categories
        format.html { render :edit }
      end
    end
  end

  # GET /pcs/1/release
  #
  # perform release; only possible on PCP Subject not closed and by
  # owner or deputy.

  def update_release
    # PCP Subject must not be closed yet
    if @pcp_curr_step.status_closed? then
      render_bad_logic t( 'pcp_subjects.msg.subj_closed' )
      return
    end
    # current user must be owner or deputy for the acting group
    unless @pcp_subject.user_is_owner_or_deputy?( current_user.id, @pcp_curr_step.acting_group_index )
      render_bad_logic t( 'pcp_subjects.msg.nop_release' )
      return
    end 
    # make sure preconditions for all items are met to release this subject to the next step:
    # i.e. (1) item is closed, or
    #      (2) item is new for this step and without comments, or
    #      (3) item has at least one comment public for this step
    open_pi = 0
    @pcp_subject.pcp_items.each do |pi|
      next if pi.closed?
      pcs = pi.pcp_comments
      if pcs.empty? then
        next if pi.pcp_step == @pcp_curr_step
      else
        next if pcs.last.pcp_step == @pcp_curr_step && pcs.is_public.count > 0
      end
      open_pi += 1
    end
    respond_to do |format|
      if open_pi > 0 then
        # ignore release request
        set_final_breadcrumb( :show )
        flash.now[ :notice ] = I18n.t( 'pcp_subjects.msg.rel_not_ok', count: open_pi )
        format.html { render :show }
      else
        # process request
        case @pcp_curr_step.release_type
        when 0
          @pcp_new_step = @pcp_subject.pcp_steps.create
          @pcp_new_step.create_release_from( @pcp_curr_step, current_user )
          PcpStep.transaction do
            if @pcp_new_step.save && @pcp_curr_step.save then
              @pcp_subject.pcp_items.each { |pi| pi.release_item }
              flash[ :notice ] = I18n.t( 'pcp_subjects.msg.release_ok' )
              format.html { redirect_to action: :show_release, id: @pcp_subject.id, step_no: @pcp_curr_step.step_no }
            else
              format.html { render :show }
            end
          end
        when 1
          @pcp_curr_step.set_release_data( current_user )
          PcpStep.transaction do
            if @pcp_curr_step.save then
              @pcp_subject.pcp_items.each{ |pi| pi.release_item }
              flash[ :notice ] = I18n.t( 'pcp_subjects.msg.release_ok' )
              format.html { redirect_to action: :show_release, id: @pcp_subject.id, step_no: @pcp_curr_step.step_no }
            else
              format.html { render :show }
            end
          end
        else
          set_final_breadcrumb( :show )
          format.html { render :show }
        end
      end
    end
  end

  # DELETE /pcs/1

  def destroy
    unless @pcp_subject.permitted_to_access?( current_user, :to_delete )
      render_no_permission
      return
    end
    @pcp_subject.destroy
    respond_to do |format|
      format.html { redirect_to pcp_subjects_url, notice: I18n.t( 'pcp_subjects.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_pcp_subject
      @pcp_subject = PcpSubject.find( params[ :id ])
      most_recent_steps = @pcp_subject.current_steps
      @pcp_curr_step = most_recent_steps[ 0 ]
      @pcp_prev_step = most_recent_steps[ 1 ] 
      @pcp_viewing_group = @pcp_subject.viewing_group_map( current_user.id, [ 'edit', 'update' ].include?( action_name ) ? :to_modify : :to_access )
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def pcp_subject_params
      params.require( :pcp_subject ).permit( @valid_subject_params << { pcp_steps_attributes: @valid_step_params })
    end

    def filter_params
      params.slice( :ff_id, :ff_titl, :ff_igrp, :ff_note ).clean_up
    end

    # define list of parameters which can be modified

    def set_valid_params
      if @pcp_subject.nil? || @pcp_subject.id.nil? then
        # assume new/create
        @valid_step_params = []
        @valid_subject_params = [ :pcp_category_id, :title, :note, :project_doc_id, :report_doc_id ]
      else
        if @pcp_curr_step.in_presenting_group? then
          if @pcp_curr_step.status_closed? then
            @valid_step_params = []
            @valid_subject_params = [ :archived ]
          else
            @valid_step_params = [ :id, :subject_version, :note, :subject_date, :due_date, :report_version, :release_notice ]
            @valid_subject_params = [ :pcp_category_id, :title, :note, :project_doc_id, :report_doc_id, :p_group_id, :p_owner_id, :p_deputy_id ]
          end
        else
          @valid_step_params = [ :id, :note, :due_date, :new_assmt, :report_version, :release_notice ]
          @valid_subject_params = [ :c_group_id, :c_owner_id, :c_deputy_id ]
        end
      end
    end

    # retrieve those PCP Categories for which the current user may create PCP Subjects
    # for, i.e. she must have :to_create permission for the current controller and 
    # the PCP Category must have either c_group_id or p_group_id set for these groups.

    def permitted_categories
      pg = current_user.permitted_groups( FEATURE_ID_MY_PCP_SUBJECTS, :to_create )
      PcpCategory.permitted_groups( pg ).collect{ |c| [ c.label, c.id ]}
    end

    # all both owners, deputies and all members of this subject may view information
    # about this PCP Subject:

    def permission_to_view?
      @pcp_viewing_group > 0
    end

    # check if current user has permission to modify PCP Subject or PCP Step now

    def permission_to_modify?
      PcpSubject.same_group?( @pcp_curr_step.acting_group_index, @pcp_viewing_group )
    end

    # prepare set of statistics for display in forms, i.e. no of items and 
    # current assessment

    def get_item_stats
      @pcp_item_stats = @pcp_subject.get_item_stats
      @pcp_item_count = @pcp_item_stats.inject(:+)
    end

    # prepare list of groups to select from

    def get_groups_for_select
      Group.active_only.participants_only.collect{ |g| [ g.code_and_label, g.id ]}
    end

end
