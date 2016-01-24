require './lib/assets/work_flow_helper_dyn.rb'
class DsrStatusRecordsController < ApplicationController
  include StatsResultHelper
  initialize_feature FEATURE_ID_DSR_STATUS_RECORDS, FEATURE_ACCESS_INDEX, FEATURE_CONTROL_GRPWF, 1
  before_action :set_general_workflow
  before_action :set_dsr_status_record,  only: [ :show, :edit, :update, :destroy, :add, :update_b_one ]
  before_action :set_dsr_status_records, only: [ :index ]

  # GET /dsrs

  def index
    @filter_fields = filter_params
    @filter_states = @workflow.all_states_for_select
    @filter_groups = permitted_groups( :to_index )
    @filter_states = @workflow.all_states_for_select( 0 )
    @filter_doc_groups = DsrDocGroup.all.collect    { |g| [ g.code_with_id, g.id ]}
    @submission_groups = SubmissionGroup.all.collect{ |g| [ g.code_with_id, g.id ]}
  end

  # GET /dsrs/stats
  # GET /dsrs/1/stats

  # TODO fix breadcrumbs: Currently, breadcrumbs does not support this type of nested feature
  # TODO this is not very DRY yet: stats 1/7, 2/8, 3/9, 4/10, 5/11, 6/12 are almost identical,
  #      view differs currently only in title and table heading for the grouping variable...

  def stats
    # determine basic parameters
    case params[ :id ]
    when '1','2','3','4','5','6'
      group_var_c = :sender_group_id
      group_var_b = :sender_group_b_id
      group_model = Group
      @dsr_groups = []
    when '7','8','9','10','11','12'
      group_var_c = :submission_group_id
      group_var_b = :submission_group_b_id
      group_model = SubmissionGroup
      @dsr_groups = [[ nil, t('dsr_status_records.form.no_group')]]
    when '13','14'
      group_var_c = :prep_activity_id
      group_var_b = :prepare_progress
    when '15','16'
      group_var_c = :subm_activity_id
      group_var_b = :approve_progress
    end

    case params[ :id ]
    when '1','3','7','9'
      @dsr_stats_c = query_stats( group_var_c, :document_status, 'SUM( quantity )')
      @dsr_stats_b = query_stats( group_var_b, :document_status_b, 'SUM( quantity_b )')

    when '2','4','8','10'
      @dsr_stats_c = query_stats( group_var_c, :document_status, 'SUM( weight )' )
      @dsr_stats_b = query_stats( group_var_b, :document_status_b, 'SUM( weight_b )')

    when '5','11'
      @dsr_stats_c = query_stats( group_var_c, :current_task, 'COUNT( * )')
      @dsr_stats_b = query_stats( group_var_b, :current_task_b, 'COUNT( * )')

    when '6','12'
      @dsr_stats_c = query_stats( group_var_c, :current_status, 'COUNT( * )')
      @dsr_stats_b = query_stats( group_var_b, :current_status_b, 'COUNT( * )')

    when '13','15'
      @dsr_stats_c = query_stats( group_var_c, :document_status, 'SUM( quantity )')

    when '14','16'
      @dsr_stats_c = query_stats( group_var_c, :document_status, 'SUM( weight )')

    end 

    unless @dsr_stats_c.nil? then
      case params[ :id ]
      when '3','4','9','10'
        # add progress * count/weight
        @dsr_groups.concat group_model.pluck( :id, :code )
        p = DsrProgressRate.pluck( :id, :document_progress )
        @dsr_stats_c.map!{ |r| r << r[ 2 ] * p.assoc( r[ 1 ])[ 1 ]}
        @dsr_stats_b.map!{ |r| r << r[ 2 ] * p.assoc( r[ 1 ])[ 1 ]} unless @dsr_stats_b.nil?
        @dsr_stats_d = merge_stats( @dsr_stats_c, @dsr_stats_b, 2, 2 )
        @dsr_stats_st = sub_totals( @dsr_stats_d, 1, 4 )
        @dsr_stats_gt = grand_total( @dsr_stats_st, 4 )
      when '1','2','5','6','7','8','11','12'
        @dsr_groups.concat group_model.pluck( :id, :code )
        @dsr_stats_d = merge_stats( @dsr_stats_c, @dsr_stats_b, 2, 1 )
        @dsr_stats_st = sub_totals( @dsr_stats_d, 1, 2 )
        @dsr_stats_oa = over_alls( @dsr_stats_d, 1, 2 )
        @dsr_stats_gt = grand_total( @dsr_stats_st, 2 )
      when '13','14','15','16'
        # map progress to document status
        p = DsrProgressRate.pluck( :id, group_var_b )
        @dsr_stats_c.map!{ |r| r << r[ 2 ] * p.assoc( r[ 1 ])[ 1 ]}
        # compute totals per activity
        @dsr_stats_st = sub_totals( @dsr_stats_c, 1, 2 )
        # add activity information (somewhat like join, removing all documents for which there is no activity)
        a = ProgrammeActivity.order( :project_id, :activity_id ).pluck( :id, :project_id, :activity_id, :activity_label, :start_date, :finish_date )
        @dsr_stats_st.map!{ |r| r + Array( a.assoc( r[ 0 ]))} unless a.empty?
      end
      render "stats_#{ params[ :id ]}"
    end
  end

  # GET /dsrs/1

  def show
  end

  # GET /dsrs/info

  def info
    set_final_breadcrumb( :wf_info )
  end

  # GET /dsrs/1/update - update baseline for this record

  def update_b_one
    if current_user.permission_to_access( feature_identifier, :to_update ) == 4 then
      @dsr_status_record.save_baseline  
      @dsr_status_record.save
      redirect_to @dsr_status_record, notice: t( 'dsr_status_records.msg.update_ok' )
    else
      render_no_permission
    end
  end

  # GET /dsrs/update - update baseline for all records

  def update_b_all
    if current_user.permission_to_access( feature_identifier, :to_update ) == 4 then
      DsrStatusRecord.find_each do |d|
        d.save_baseline
        d.save
      end
      redirect_to dsr_status_records_url
    else
      render_no_permission
    end
  end

  # GET /dsrs/new

  def new
    @dsr_status_record = DsrStatusRecord.new
    # check permission for this user and display only those workflows which
    # she is allowed to create
    @allowed_workflows = current_user.permitted_workflows( feature_identifier )
    if @allowed_workflows.blank?
      redirect_to @dsr_status_record, notice: t( 'dsr_status_records.msg.you_no_new')
    else
      prepare_collections( :to_create )
      init_current_workflow( 0 )
   end
  end

  # GET /dsrs/1/new = add
  # create a new document based on attributes of an existing document

  def add
    # check permission for this user and display only those workflows which
    # she is allowed to create
    @allowed_workflows = current_user.permitted_workflows( feature_identifier )
    if @allowed_workflows.blank?
      redirect_to @dsr_status_record, notice: t( 'dsr_status_records.msg.you_no_new')
    else
      @dsr_sender_groups = permitted_groups( :to_create )
      @dsr_previous_record = @dsr_status_record.id
      @dsr_status_record.id = nil
      @dsr_status_record.document_status = 0
      @dsr_status_record.init_baseline
      if @dsr_show_add_checkbox = @dsr_status_record.possible_to_derive? then
        @dsr_status_record.sub_frequency = 1 # 'single (from group)'
        @dsr_status_record.weight = @dsr_status_record.weight / @dsr_status_record.quantity
        @dsr_status_record.quantity = 1
        flash.now[ :notice ] = t( 'dsr_status_records.msg.add_created' )
      end
   end
  end

  # GET /dsrs/1/edit

  def edit
    @dsr_sender_groups = permitted_groups( :to_update )
  end

  # POST /dsrs

  def create
    init_current_workflow( 0, params.fetch( :sender_group_id, nil ))
    @dsr_status_record = DsrStatusRecord.new( dsr_status_record_params )
    # check permission for this user to create a workflow of this type
    unless current_user.permission_for_task?( feature_identifier, 0, 0 ) then
      redirect_to @dsr_status_record, notice: t( 'dsr_status_records.msg.you_no_new')
    else
      # permission granted to create workflow
      update_status_and_task
      update_add_source = params.fetch( :check_box_add, 0 )
      dsr_add_source = DsrStatusRecord.find_by_id( update_add_source )
      respond_to do |format|
        if @dsr_status_record.valid? then
          if dsr_add_source.try( :possible_to_derive, @dsr_status_record ) then
            @dsr_status_record.transaction do
              dsr_add_source.derive_this( @dsr_status_record )
              dsr_add_source.save
              @dsr_status_record.save
            end
            notice_is = t( 'dsr_status_records.msg.add_ok' )
          else
            @dsr_status_record.save
            notice_is = t( 'dsr_status_records.msg.new_ok' )
          end
          format.html { redirect_to @dsr_status_record, notice: notice_is }
        else
          prepare_collections( :to_create )
          format.html { render :new }
        end
      end
    end
  end

  # PATCH/PUT /dsrs/1

  def update
    # check permissions - again, to be on the safe side
    if @workflow.permitted_params.length == 0 and not @workflow.status_change_possible? then
      redirect_to @dsr_status_record, notice: t( 'dsr_status_records.msg.no_edit_now' )
    elsif !current_user.permission_for_task?( feature_identifier, 0, @dsr_status_record.current_task ) then
      redirect_to @dsr_status_record, notice: t( 'dsr_status_records.msg.you_no_edit' )
    else
      # get ready to update record(s)
      dsr_str_params = dsr_status_record_params
      dsr_sub_params = dsr_submission_params
      @dsr_status_record.assign_attributes( dsr_str_params ) unless dsr_str_params.empty?
      @dsr_current_submission.assign_attributes( dsr_sub_params ) unless @dsr_current_submission.nil? || dsr_sub_params.empty?
      update_status_and_task( params.fetch( :next_status_task, 0 ).to_i )
      perform_transaction = @dsr_status_record.errors.empty?
      perform_transaction &&= @dsr_current_submission.valid? unless @dsr_current_submission.nil?
      respond_to do |format|
        if perform_transaction && @dsr_status_record.valid? then
          @dsr_status_record.transaction do
            @dsr_current_submission.save! unless @dsr_current_submission.nil?
            @dsr_status_record.dsr_current_submission = @dsr_current_submission
            @dsr_status_record.save!
          end
          format.html { redirect_to @dsr_status_record, notice: t( 'dsr_status_records.msg.edit_ok' )}
        else
          @dsr_sender_groups = permitted_groups( :to_update )
          format.html { render :edit }
        end
      end
    end
  end

  # DELETE /dsrs/1

  def destroy
    @dsr_status_record.destroy
    respond_to do |format|
      format.html { redirect_to dsr_status_records_url, notice: t( 'dsr_status_records.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_dsr_status_record
      @dsr_status_record = DsrStatusRecord.find( params[ :id ] )
      @dsr_receiver_groups = all_groups
      @submission_groups = SubmissionGroup.all.collect{ |g| [ g.code_with_id, g.id ]}
      @dsr_current_submission = @dsr_status_record.dsr_current_submission
      # for add consider the new record and not the current one
      if action_name == 'add' then
        init_current_workflow( 0, @dsr_status_record.sender_group_id )
      else
        init_current_workflow( 0, @dsr_status_record.sender_group_id, @dsr_status_record.current_status, @dsr_status_record.current_task )
      end
      @workflow.validate_instance if $DEBUG
    end

    def set_dsr_status_records
      @dsr_status_records = DsrStatusRecord.filter( filter_params ).paginate( page: params[ :page ])
    end

    def filter_params
      params.slice( :ff_id, :ff_group, :ff_title, :ff_docgr, :ff_subgr, :ff_docsts, :ff_wflsts ).clean_up
    end

    def prepare_collections( to_action )
      @dsr_sender_groups = permitted_groups( to_action )
      @dsr_receiver_groups = all_groups
      @submission_groups = SubmissionGroup.all.collect{ |g| [ g.code_with_id, g.id ]}
    end      

    # Never trust parameters from the scary internet, only allow the white list through.

    def dsr_status_record_params
      params.require( :dsr_status_record ).permit( @workflow.permitted_params, :next_status_task, :check_box_add )
    end

    def dsr_submission_params
      p = params.fetch( :dsr_submission, {})
      p.permit( @workflow.permitted_params ) unless p.nil?
    end      

    # prepare list of groups for selections

    def permitted_groups( action )
      pg = current_user.permitted_groups( feature_identifier, action, :id )
      Group.permitted_groups( pg ).all.collect{ |g| [ g.code_with_id, g.id ]}
    end

    def all_groups
      Group.all.collect{ |g| [ g.code_with_id, g.id ]}
    end

    # collect common method calls

    def update_status_and_task( i = 1 )
      @workflow.update_status_task( i )
      if ready_for_next_status_task? then
        @dsr_status_record.current_task = @workflow.wf_updated_task
        @dsr_status_record.current_status = @workflow.wf_updated_status
        case @dsr_status_record.current_task
        when 3
          @dsr_status_record.actl_prep_start ||= DateTime.now
        when 5
          if @dsr_status_record.current_status == 7 then # reconsider release, invalidate current submission data
            @dsr_current_submission.reset_fields unless @dsr_current_submission.nil?
          end
        when 6
          if @dsr_status_record.dsr_current_submission.nil? || @dsr_status_record.dsr_current_submission.actl_submission then
            @dsr_current_submission = DsrSubmission.new
            @dsr_current_submission.submission_no = @dsr_status_record.dsr_submissions.count + 1
            @dsr_current_submission.dsr_status_record = @dsr_status_record
          end            
          @dsr_current_submission.plnd_submission = @dsr_current_submission.submission_no == 1 ? @dsr_status_record.plnd_submission_1 : @dsr_status_record.next_submission
        when 7
          d = DateTime.now
          @dsr_status_record.actl_submission_1 ||= d
          @dsr_current_submission.actl_submission = @dsr_current_submission.submission_no == 1 ? @dsr_status_record.actl_submission_1 : @dsr_current_submission.actl_submission || d
        when 8
          @dsr_current_submission.actl_response ||= DateTime.now
        when 10  
          @dsr_status_record.actl_completion ||= DateTime.now
        end
        update_document_status
      end
    end

    def ready_for_next_status_task?
      case @workflow.wf_updated_status
      when 2 # starting to prepare document
        @dsr_status_record.check_prepare_readiness
      when 6 # ready for submission?
        @dsr_status_record.check_submit_readiness
      when 10 # continue with approval status B
        check_approval_status( DsrSubmission::DSR_RESPONSE_STATUS_B )
      when 11 # continue with approval status C
        check_approval_status( DsrSubmission::DSR_RESPONSE_STATUS_C )
      when 13 # continue with approval status A
        check_approval_status( DsrSubmission::DSR_RESPONSE_STATUS_A )
      when 14 # continue with approval status D
        check_approval_status( DsrSubmission::DSR_RESPONSE_STATUS_D )
      when 15 # submission for information only
        @dsr_status_record.check_submit_for_info_only
      when 17 # withdraw?
        @dsr_status_record.check_withdraw_readiness
      end
      @dsr_status_record.errors.empty?
    end

    def check_approval_status( s )
      unless @dsr_current_submission.response_status == s then \
        @dsr_status_record.errors.add( :base, I18n.t( 'dsr_status_records.msg.bad_resp_sts' ))
      end
    end


    # determine document status from current status
    # 0 - planned
    # 1 - in progress
    # 2 - in review
    # 3 - in submission
    # 4 - submitted
    # 5 - approved
    # 6 - approved with comments
    # 7 - rejected
    # 8 - completed w/o approval
    # 9 - updated
    # 10 - withdrawn/doc group complete

    def update_document_status
      @dsr_status_record.document_status = 
    #     0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 ] 
        [ 0, 0, 0, 1, 1, 2, 3, 3, 4, 4,  6,  7,  9,  5,  8,  8,  8, 10, 10 ][ @dsr_status_record.current_status ]
    end

    # setup workflow - call once to initialize object

    def set_general_workflow
      @workflow = WorkFlowHelperDyn.new([
        [ # single workflow only
          [[ 0, 1 ]],
          [[ 1, 2 ],[ 17, 10 ],[ 18, 10 ]],
          [[ 2, 3 ],[ 17, 10 ]],
          [[ 3, 3 ],[ 4, 4 ],[ 17, 10 ]],
          [[ 3, 3 ],[ 5, 5 ],[ 17, 10 ]],
          [[ 4, 4 ],[ 6, 6 ],[ 16, 10 ],[ 17, 10 ]],
          [[ 7, 5 ],[ 8, 7 ],[ 15, 10 ]],
          [[ 9, 8 ]],
          [[ 10, 9 ],[ 11, 9 ],[ 13, 10 ],[ 14, 10 ]],
          [[ 12, 4 ]],
          [[ -1, 10 ]]
        ],
        ],
        controller_name )
    end

    # initialize the current workflow: since this method sets up the parameter
    # information, it must not be called more than once; be aware that the
    # group_id is needed to determine the respective access level - for new
    # records, I will take the maximum level returned by permission_to_access
    # assuming that the user has only rights for this group or knows his rights.

    def init_current_workflow( index, group_id = nil, status = 0, task = 0 )
      raise ArgumentError.new( 'init_current_workflow must not be called twice' ) \
        unless @workflow.wf_current_index.nil? 
      @workflow.initialize_current( index, status, task, 
        current_user.permission_to_access( self.feature_identifier, map_action_to_permission, group_id ))
      
      # add eligable [ parameters ] for each [ access level ( nil/none, edit, show )] and each [ workflow task ]
      # access level 1 = minimum parameters needed to perform workflow task
      # access level 2 = standard set of parameters, r/w depending of workflow task
      # access level 3 = standard set of parameters + baseline parameters to view
      # access level 4 = standard set of parameters + baseline parameters to edit

      @workflow.add_parameters([ :title, :sender_group_id, :receiver_group_id, :sender_doc_id, :receiver_doc_id, :project_doc_id, :sub_purpose ],
                                          [ :edit, :edit, :edit, :edit ],[ 0, 1, 2 ])
      @workflow.add_parameters([ :title, :sender_group_id, :receiver_group_id, :sender_doc_id, :receiver_doc_id, :project_doc_id ],
                                          [ :show, :show, :edit, :edit ],[ 3, 4, 5, 6, 7, 8, 9, 10 ])
      @workflow.add_parameters([ :document_status_b, :sender_group_b_id, :quantity_b, :weight_b, :current_status_b, :current_task_b, :plnd_prep_start_b, :plnd_completion_b ],
                                          [   nil,   nil, :show, :edit ], [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ])
      @workflow.add_parameters([ :sub_frequency, :quantity, :weight, :dsr_doc_group_id, :prep_activity_id, :estm_prep_start ],
                                          [   nil, :edit, :edit, :edit ], [ 0, 1, 2 ])
      @workflow.add_parameters([ :sub_frequency, :quantity, :weight, :dsr_doc_group_id, :prep_activity_id, :estm_prep_start ],
                                          [   nil, :show, :show, :edit ], [ 3, 4, 5, 6, 7, 8, 9, 10 ])
      @workflow.add_parameters([ :estm_completion ], [ nil, :edit, :edit, :edit ], [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ])
      @workflow.add_parameters([ :plnd_prep_start, :plnd_completion ],
                                                   [   nil, :show, :show, :show ], [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ])
      @workflow.add_parameters([ :sub_purpose ],   [ :show, :show, :show, :edit ], [ 3, 4, 5 ])
      @workflow.add_parameters([ :sub_purpose   ], [ :show, :show, :show, :show ], [ 6, 7, 8, 9, 10 ])
      @workflow.add_parameters([ :actl_prep_start ],[   nil, :show, :edit, :edit ], [ 3, 4, 5, 7, 8, 9, 10 ])
      @workflow.add_parameters([ :estm_completion, :actl_completion ],[   nil, :show, :show, :edit ], [ 10 ])
      if @dsr_status_record.try( :submission_required? )then
        @workflow.add_parameters([ :plnd_submission_b ],[   nil,   nil, :show, :edit ], [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ])
        @workflow.add_parameters([ :submission_group_id, :subm_activity_id ],[   nil, :edit, :edit, :edit ], [ 0, 1, 2 ])
        @workflow.add_parameters([ :submission_group_id, :subm_activity_id ],[   nil, :show, :show, :edit ], [ 3, 4, 5, 6, 7, 8, 9, 10 ])
        @workflow.add_parameters([ :plnd_submission_1 ],[   nil, :show, :show, :show ], [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ])
        @workflow.add_parameters([ :estm_submission   ],[   nil, :edit, :edit, :edit ], [ 0, 1, 2, 3, 4, 5 ])
        @workflow.add_parameters([ :estm_submission   ],[   nil, :show, :show, :edit ], [ 6, 7, 8, 9, 10 ])
        @workflow.add_parameters([ :actl_submission_1 ],[   nil, :show, :show, :edit ], [ 4, 5, 6, 7, 8, 9, 10 ])
        @workflow.add_parameters([ :next_submission   ],[ :edit, :edit, :edit, :edit ], [ 3, 4, 5, 6, 8, 9 ])
        @workflow.add_parameters([ :next_submission   ],[   nil, :show, :show, :show ], [ 10 ])
        # for the submission record:
        @workflow.add_parameters([ :sender_doc_id_version, :project_doc_id_version, :receiver_doc_id_version,
                                   :submission_receiver_doc_id, :submission_project_doc_id,
                                   :xpcd_response, :xpcd_response_delta ],[ :edit, :edit, :edit, :edit ], [ 6 ])
        @workflow.add_parameters([ :sender_doc_id_version, :project_doc_id_version, :receiver_doc_id_version,
                                   :submission_receiver_doc_id, :submission_project_doc_id, :actl_submission, :xpcd_response, :xpcd_response_delta ],[ :show, :show, :edit, :edit ], [ 8 ])
        @workflow.add_parameters([ :response_sender_doc_id, :response_project_doc_id, :actl_response, :response_status ],[ :edit, :edit, :edit, :edit ],[ 8 ])
        @workflow.add_parameters([ :sender_doc_id_version, :project_doc_id_version, :receiver_doc_id_version,
                                   :submission_receiver_doc_id, :submission_project_doc_id, :plnd_submission, :actl_submission, :xpcd_response,
                                   :response_sender_doc_id, :response_project_doc_id, :actl_response, :response_status ],[ :show, :show, :show, :show ],[ 0, 1, 2, 3, 4, 5, 7, 9, 10 ])
      end
      # add this to the list of permitted params so we can always edit this field
      @workflow.add_parameters([ :notes ], [ :edit, :edit, :edit, :edit ], [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ])
      @workflow.validate_instance
      #Rails.logger.debug ">>> params to edit: " + @workflow.wfd_edit_parameters.inspect
      #Rails.logger.debug ">>> params to show: " + @workflow.wfd_show_parameters.inspect
    end

    # provide a subtitle for views when needed

    def dsr_sub_title
      if @workflow.current_access_level > 2 then
        t( 'dsr_status_records.form.sub_title', bl_date: 
          @dsr_status_record.baseline_date.nil? ? t( 'dsr_status_records.form.no_bl_date' ) : l( @dsr_status_record.baseline_date, format: :db_time ))
      end
    end
    helper_method :dsr_sub_title

    # Create and fire query for stats:
    # - group_var_1, group_var_2 are the grouping variables
    # - stat_var is the grouping function

    def query_stats( group_var_1, group_var_2, stat_var )
      DsrStatusRecord.connection.select_rows( sprintf( 'SELECT %1$s, %2$s, %3$s FROM dsr_status_records GROUP BY %1$s, %2$s', group_var_1, group_var_2, stat_var ))
    end

end
