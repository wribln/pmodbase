require './lib/assets/work_flow_helper.rb'
class RfcStatusRecordsController < ApplicationController

  initialize_feature FEATURE_ID_RFC_STATUS_RECORDS, FEATURE_ACCESS_INDEX, FEATURE_CONTROL_GRPWF, 3
  
  before_action :set_general_workflow
  before_action :set_rfc_status_record,  only: [ :show, :edit, :update, :destroy ]
  before_action :set_rfc_status_records, only: [ :index ]

  # GET /rsrs

  def index
    @filter_fields = filter_params
    @filter_groups = permitted_groups( :to_index )
    @filter_states = @workflow.all_states_for_select
  end

  # GET /rsrs/info

  def info_workflow
  end

  # GET /rsrs/stats

  def stats
    @stats = RfcStatusRecord.group( :rfc_type, :current_status ).count
  end

  # GET /rsrs/1

  def show
  end

  # GET /rsrs/new - user must make a choice which workflow record to create

  def new
    @rfc_status_record = RfcStatusRecord.new
    # check permission for this user and display only those workflows which
    # she is allowed to create
    @allowed_workflows = current_user.permitted_workflows( feature_identifier )
    if @allowed_workflows.blank?
      redirect_to @rfc_status_record, notice: t( 'rfc_status_records.msg.you_no_new')
    end
  end

  # POST /rsrs

  def create
    @rfc_status_record = RfcStatusRecord.new( params.require( :rfc_status_record ).permit( :rfc_type ))
    # check permission for this user to create a workflow of this type
    unless current_user.permission_for_task?( feature_identifier, @rfc_status_record.rfc_type, 0 ) then
      redirect_to @rfc_status_record, notice: t( 'rfc_status_records.msg.you_no_new')
    else
      # permission granted to create workflow
      @workflow.initialize_current( @rfc_status_record.rfc_type )
      update_status_and_task
      respond_to do |format|
        if @rfc_status_record.valid? # this should always be the case...
          # create version 0 RfC Document for this workflow
          @rfc_document = RfcDocument.new
          @rfc_document.account_id = current_user.id
          @rfc_status_record.transaction do
            @rfc_status_record.save
            @rfc_document.rfc_status_record_id = @rfc_status_record.id
            @rfc_document.save
          end
          format.html { redirect_to edit_rfc_status_record_path( @rfc_status_record ), notice: t( 'rfc_status_records.msg.new_ok' )}
        else
          format.html { render :new }
        end
      end
    end
  end

  # GET /rsrs/1/edit

  def edit
    if @workflow.permitted_params.length == 0 and not @workflow.status_change_possible? then
      redirect_to @rfc_status_record, notice: t( 'rfc_status_records.msg.no_edit_now' )
    elsif !current_user.permission_for_task?( feature_identifier, @rfc_status_record.rfc_type, @rfc_status_record.current_task ) then
      redirect_to @rfc_status_record, notice: t( 'rfc_status_records.msg.you_no_edit' )
    else
      case @rfc_status_record.rfc_type
        when 0 # incoming
          @author_groups, @resp_groups = all_groups, permitted_groups( :to_update )
        when 1 # outgoing
          @author_groups, @resp_groups = permitted_groups( :to_update ), all_groups
        when 2 # copy
          @author_groups = @resp_groups = all_groups
      end
    end
  end

  # PATCH/PUT /rsrs/1

  def update
    # check permissions - again, to be on the safe side
    if @workflow.permitted_params.length == 0 and not @workflow.status_change_possible? then
      redirect_to @rfc_status_record, notice: t( 'rfc_status_records.msg.no_edit_now' )
    elsif !current_user.permission_for_task?( feature_identifier, @rfc_status_record.rfc_type, @rfc_status_record.current_task ) then
      redirect_to @rfc_status_record, notice: t( 'rfc_status_records.msg.you_no_edit' )
    else
      case @rfc_status_record.rfc_type
        when 0 # incoming
          @author_groups, @resp_groups = all_groups, permitted_groups( :to_update )
        when 1 # outgoing
          @author_groups, @resp_groups = permitted_groups( :to_update ), all_groups
        when 2 # copy
          @author_groups = @resp_groups = all_groups
      end
      # get ready to update record(s)
      @workflow.initialize_current( @rfc_status_record.rfc_type, @rfc_status_record.current_status, @rfc_status_record.current_task )
      update_status_and_task( params.fetch( :next_status_task ).to_i )
      rfc_params = rfc_status_record_params
      # nested rfc_document needs to be created with updated attributes
      # unless it is the initial, empty version which should remain as
      # version 0 document until someone has put some data in it
      if @rfc_document.initial_version? then
        rfc_updated = @rfc_document
      else 
        rfc_updated = RfcDocument.new( @rfc_document.attributes.except( "id" )).increment( "version" )
      end
      rfc_updated.account_id = current_user.id
      save_rfc_doc = false
      # check if RfcDocument could possibly be modified by this user
      if rfc_params.include?( :rfc_document ) then
        rfc_original = rfc_updated.dup
        rfc_updated.assign_attributes( rfc_params.delete( :rfc_document ))
        save_rfc_doc = rfc_updated.modified?( rfc_original )
      end
      @rfc_status_record.assign_attributes( rfc_params ) unless rfc_params.empty?
      respond_to do |format|
        if @rfc_status_record.valid? && rfc_updated.valid? then
          @rfc_status_record.transaction do
            @rfc_status_record.save!
            rfc_updated.save! if save_rfc_doc
          end
          format.html { redirect_to @rfc_status_record, notice: t( 'rfc_status_records.msg.edit_ok' )}
        else
          format.html { render :edit }
        end
      end
    end
  end

  # DELETE /rsrs/1

  def destroy
    @rfc_status_record.destroy
    respond_to do |format|
      format.html { redirect_to rfc_status_records_url, notice: t( 'rfc_status_records.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_rfc_status_record
      @rfc_status_record = RfcStatusRecord.find( params[ :id ])
      @rfc_document = @rfc_status_record.rfc_documents.first
      @workflow.initialize_current( @rfc_status_record.rfc_type, @rfc_status_record.current_status, @rfc_status_record.current_task )
      @workflow.validate_instance if $DEBUG
    end

    def set_rfc_status_records   
      @rfc_status_records = RfcStatusRecord.filter( filter_params ).paginate( page: params[ :page ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    # Due to the nature of this controller (variable white lists and parameters outside
    # the main model), the permitted record parameter list may be empty

    def rfc_status_record_params
      params.include?( :rfc_status_record ) ? params.require( :rfc_status_record ).permit( @workflow.permitted_params ) : {}
    end

    def filter_params
      params.slice( :ff_id, :ff_type, :ff_agrp, :ff_rgrp, :ff_titl, :ff_stts ).clean_up
    end

    # collect common method calls:

    def update_status_and_task( i = 1)
      @workflow.update_status_task( i )
      @rfc_status_record.current_task = @workflow.wf_updated_task
      @rfc_status_record.current_status = @workflow.wf_updated_status
    end

    # prepare list of groups for selections

    def permitted_groups( action )
      pg = current_user.permitted_groups( FEATURE_ID_RFC_STATUS_RECORDS, action )
      Group.permitted_groups( pg ).all.collect{ |g| [ g.code_and_label, g.id ]}
    end

    def all_groups
      Group.all.collect{ |g| [ g.code_and_label, g.id ]}
    end

    # set general workflow options

    def set_general_workflow
      @workflow = WorkFlowHelper.new([
        [ # incoming
         [[ 0, 1 ]],
         [[ 1, 2 ]],
         [[ 2, 3 ]],
         [[ 3, 2 ],[ 4, 4 ]],
         [[ 5, 3 ],[ 6, 5 ]],
         [[ 7, 3 ],[ 8, 6 ]],
         [[ 9, 7 ]],
         [[ -1, 7 ]]
        ],
        [ # outgoing
         [[ 0, 1 ]],
         [[ 1, 2 ]],
         [[ 2, 3 ],[ 5, 4 ]],
         [[ 3, 3 ],[ 4, 4 ],[ 7, 5 ]],
         [[ 6, 2 ],[ 13, 9 ]],
         [[ 8, 6 ]],
         [[ 9, 7 ]],
         [[ 10, 8 ]],
         [[ 11, 9 ],[ 12, 9 ]],
         [[ -1, 9 ]]
        ],
        [ # copy
         [[ 0, 1 ]],
         [[ 1, 2 ]],
         [[ 2, 3 ]],
         [[ -1, 3 ]]
        ],
        ],
        [                                                                                                                                   
         [                                                                                                                                  
          [],                                                                                                                               
          [ :title, :asking_group_id, :answering_group_id, :project_doc_id, :asking_group_doc_id, :answering_group_doc_id,
            rfc_document: [ :question, :note ]],                  
          [ :title, :answering_group_id ],                                                                                                    
          [ :title, :answering_group_doc_id ],                                                                                                                               
          [],                                                                                                                               
          [],                                                                                                                               
          [],                                                                                                                               
          []                                                                                                                                
         ],                                                                                                                                 
         [                                                                                                                                  
          [],                                                                                                                               
          [ :title, :asking_group_id, :answering_group_id, :project_doc_id, :asking_group_doc_id,
            rfc_document: [ :question, :note ]],
          [ :title, :answering_group_id ],
          [ :title, :answering_group_id ],
          [ :title ],
          [ :project_doc_id ],
          [],
          [ :answering_group_doc_id ],
          [],
          []
         ],
         [
          [],
          [ :title, :asking_group_id, :answering_group_id, :project_doc_id, :asking_group_doc_id, :answering_group_doc_id,
            rfc_document: [ :question, :answer, :note ]],
          [:title],
          []
         ]
        ],
        controller_name )
      @workflow.validate_instance if $DEBUG
    end

end
