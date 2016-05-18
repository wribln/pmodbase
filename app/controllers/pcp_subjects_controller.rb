class PcpSubjectsController < ApplicationController
  before_action :set_pcp_subject,  only: [ :show, :edit, :info_history, :update, :destroy, :update_release, :show_release ]
  before_action :set_valid_params, only: [ :edit, :new, :update, :create ]

  initialize_feature FEATURE_ID_PCP_SUBJECTS, FEATURE_ACCESS_VIEW, FEATURE_CONTROL_CUG + FEATURE_CONTROL_GRP

# GET /ors

  def index
    @filter_fields = filter_params
    @filter_groups = permitted_groups( :to_index )
    @pcp_subjects = PcpSubject.filter( @filter_fields ).all_active.includes( :pcp_steps ).paginate( page: params[ :page ])
  end

  # GET /pcs/1

  def show
  end

  # GET /pcs/1/info - history

  def info_history
  end

  # GET /pcs/1/reldoc/1

  def show_release
    @pcp_curr_step = @pcp_subject.pcp_steps.released.where( step_no: params[ :step_no ]).first
    if @pcp_curr_step then
      @pcp_items = PcpItem.released_until( @pcp_subject, @pcp_curr_step.step_no ).includes( :pcp_comments, :pcp_step )
#test      @pcp_items = @pcp_subject.pcp_items.includes( :pcp_comments, :pcp_step )
      render :reldoc, layout: 'plain_print'
    else
      render file: 'public/404.html', status: :not_found
    end
  end

  # GET /pcs/new

  def new
    @pcp_subject = PcpSubject.new
    @pcp_categories = permitted_categories
  end

  # GET /pcs/1/edit

  def edit
    permission_to_modify?
    @pcp_categories = permitted_categories
    @pcp_groups = permitted_groups( :to_update )
  end

  # POST /pcs

  def create
    @pcp_subject = PcpSubject.new( pcp_subject_params )
    if @pcp_subject.permitted_to_create?( current_user ) then
      @pcp_subject.p_owner_id = current_user.id
      @pcp_curr_step = @pcp_subject.pcp_steps.build( step_no: 0, prev_assmt: 0 )
      # this works due to the AutosaveAssocation
      respond_to do |format|
        if @pcp_subject.save then
          format.html { redirect_to @pcp_subject, notice: I18n.t( 'pcp_subjects.msg.new_ok' )}
        else
          @pcp_groups = permitted_groups( :to_create )
          @pcp_categories = permitted_categories
          format.html { render :new }
        end
      end
    else
      render_no_permission
    end
  end

  # PATCH/PUT /pcs/1

  def update
    if permission_to_modify? then
      respond_to do |format|
        if @pcp_subject.update( pcp_subject_params )
          format.html { redirect_to @pcp_subject, notice: I18n.t( 'pcp_subjects.msg.edit_ok' )}
        else
          @pcp_groups = permitted_groups( :to_update )
          @pcp_categories = permitted_categories
          format.html { render :edit }
        end
      end
    end
  end

  # GET /pcs/1/release

  def update_release
    if @pcp_subject.user_is_owner_or_deputy?( current_user.id, @pcp_curr_step.acting_group_index )
      respond_to do |format|
        case @pcp_curr_step.release_type
        when 0
          @pcp_new_step = @pcp_subject.pcp_steps.create
          @pcp_new_step.create_release_from( @pcp_curr_step, current_user )
          PcpStep.transaction do
            if @pcp_new_step.save && @pcp_curr_step.save then
              flash[ :notice ] = I18n.t( 'pcp_subjects.msg.release_ok' )
              format.html { redirect_to action: :show_release, id: @pcp_subject.id, step_no: @pcp_curr_step.step_no }
            else
              format.html { render :show }
            end
          end
        when 1
          @pcp_curr_step.set_release_data( current_user )
          if @pcp_curr_step.save then
            flash[ :notice ] = I18n.t( 'pcp_subjects.msg.release_ok' )
            format.html { redirect_to action: :show_release, id: @pcp_subject.id, step_no: @pcp_curr_step.step_no }
          else
            format.html { render :show }
          end
        else
          set_final_breadcrumb( :show )
          format.html { render :show }
        end
      end
    else
      render_no_permission
    end
  end

  # DELETE /pcs/1

  def destroy
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
      @pcp_viewing_group = @pcp_subject.viewing_group_map( current_user.id )
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
            @valid_step_params = [ :id, :subject_version, :note, :subject_date, :due_date, :report_version ]
            @valid_subject_params = [ :pcp_category_id, :title, :note, :project_doc_id, :report_doc_id, :p_group_id, :p_owner_id, :p_deputy_id ]
          end
        else
          @valid_step_params = [ :id, :note, :due_date, :new_assmt, :report_version ]
          @valid_subject_params = [ :c_group_id, :c_owner_id, :c_deputy_id ]
        end
      end
    end

    # retrieve categories for drop-down list box

    def permitted_categories
      pg = current_user.permitted_groups( FEATURE_ID_PCP_SUBJECTS, :to_update, :p_group_id )
      PcpCategory.permitted_groups( pg ).collect{ |c| [ c.label, c.id ]}
    end

    # prepare list of groups for selections

    def permitted_groups( action )
      pg = current_user.permitted_groups( FEATURE_ID_PCP_SUBJECTS, action, :id )
      Group.permitted_groups( pg ).all.collect{ |g| [ g.code, g.id ]}
    end

    # check if current user has permission to modify PCP subject or step: 
    # must have permission for his respective group (p_group_id or c_group_id)...
    # we wouldn't get here if the current user would not have the respective
    # permissions (edit, update, destroy)

    def permission_to_modify?
      if PcpSubject.same_group?( @pcp_curr_step.acting_group_index, @pcp_viewing_group )
        true
      else
        flash[ :notice ] = I18n.t( 'pcp_subjects.msg.no_permissn' )
        render :show, status: :forbidden
        false
      end
    end

end
