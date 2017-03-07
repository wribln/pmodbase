class SirItemsController < ApplicationController
  initialize_feature FEATURE_ID_SIR_ITEMS, FEATURE_ACCESS_USER + FEATURE_ACCESS_NBP, FEATURE_CONTROL_CUGRP

  before_action :set_sir_log,  only: [ :index, :new, :create ]
  before_action :set_sir_item, only: [ :show, :show_all, :edit, :update, :destroy ]
  before_action :set_breadcrumb
  
  # GET /sil/1/sii
 
  def index
    check_access( :to_index )
    @filter_fields = filter_params
    @sir_groups = Group.all.collect{ |g| [ g.code, g.id ]}
    @sir_phases = PhaseCode.all.order( :code ).collect{ |p| [ p.code, p.id ]}
    @sir_items = @sir_log.sir_items.active.includes( :group, :last_entry ).filter( @filter_fields ).paginate( page: params[ :page ])
  end

  # GET /sii/1
 
  def show
    check_access( :to_read )
    @sir_entries = @sir_item.sir_entries.includes([ :resp_group, :orig_group ])
    @sir_item.set_visibility( current_user.permitted_groups( feature_identifier ), @sir_entries )
    @group_stack = [ @sir_item.group_id ]
  end

  # GET /sii/1/all

  def show_all
    check_access( :to_read )
  end

  # GET /sil/1/sii/new

  def new
    check_access( :to_create )
    @sir_item = SirItem.new
    @sir_item.sir_log = @sir_log
    set_selections( :to_create )
  end

  # GET /sii/1/edit

  def edit
    @sir_log = @sir_item.sir_log
    check_access( :to_update )
    set_selections( :to_update )
  end

  # POST /sii
 
  def create
    check_access( :to_create )
    @sir_item = SirItem.new( sir_item_params )
    @sir_item.sir_log = @sir_log
    respond_to do |format|
      save_ok = false
      @sir_item.transaction do
        if @sir_item.valid?
          @sir_item.set_seqno
          @sir_item.save
          save_ok = true
        end
      end
      if save_ok
        format.html { redirect_to @sir_item, notice: I18n.t( 'sir_items.msg.create_ok' )}
      else
        set_selections( :to_create )
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /sii/1
 
  def update
    check_access( :to_update )
    respond_to do |format|
      if @sir_item.update( sir_item_params )
        format.html { redirect_to @sir_item, notice: I18n.t( 'sir_items.msg.update_ok' )}
      else
        @sir_log = @sir_item.sir_log
        set_selections( :to_update )
        format.html { render :edit }
      end
    end
  end

  # DELETE /sii/1
 
  def destroy
    check_access( :to_delete )
    @sir_log = @sir_item.sir_log
    @sir_item.destroy
    respond_to do |format|
      format.html { redirect_to sir_log_sir_items_path( @sir_log ), notice: I18n.t( 'sir_items.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_sir_log
      @sir_log = SirLog.find( params[ :sir_log_id ])
      set_breadcrumb_path( sir_log_sir_items_path( @sir_log ))
    end

    def set_sir_item
      @sir_item = SirItem.find( params[ :id ])
      @sir_log = @sir_item.sir_log
      set_breadcrumb_path( sir_log_sir_items_path( @sir_log ))
    end

    # permit any group and phase

    def set_selections( action )
      @sir_groups = Group.active_only.participants_only.collect{ |g| [ g.code_and_label, g.id ]}
      @sir_phases = PhaseCode.all.order( :code ).collect{ |p| [ p.code_and_label, p.id ]}
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def sir_item_params
      params.require( :sir_item ).permit( :sir_log_id,
        :group_id, :reference, :cfr_record_id, :label, :status,
        :category, :phase_code_id, :archived, :description )
    end

    def filter_params
      params.slice( :ff_seqno, :ff_ref, :ff_desc, :ff_stts, :ff_cat, :ff_grp, :ff_cgrp ).clean_up
    end

    def set_breadcrumb
      parent_breadcrumb( :sir_logs, sir_logs_path )
    end

    # only owner, deputy and members of this SIR log may access details
    # only members with access to group may update item

    def check_access( action )
      render_no_permission unless @sir_log.permitted_to_access?( current_user.id )
      return if [ 'index', 'new', 'create' ].include?( action_name )
      render_no_permission unless current_user.permission_to_access( feature_identifier, action, @sir_item.group_id )
    end

end
