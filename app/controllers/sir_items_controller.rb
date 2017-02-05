class SirItemsController < ApplicationController
#  initialize_feature FEATURE_ID_SIR_ITEMS, FEATURE_ACCESS_INDEX, FEATURE_CONTROL_GRP
  initialize_feature FEATURE_ID_SIR_ITEMS, FEATURE_ACCESS_USER + FEATURE_ACCESS_NBP, FEATURE_CONTROL_CUG

  before_action :set_sir_log,  only: [ :index, :new, :create ]
  before_action :set_sir_item, only: [ :show, :show_all, :edit, :update, :destroy ]
  
  # GET /sil/1/sii
 
  def index
    @sir_items = @sir_log.sir_items.active
  end

  # GET /sii/1
 
  def show
    @sir_entries = @sir_item.sir_entries.includes( :group )
    if @sir_entries.count > 0
      @sir_item.entries_ok?
      @hash_tree = SirItem.hash_tree( @sir_entries )
      @out_order = SirItem.out_order( @hash_tree, @sir_entries[ 0 ].id )
      @key_map = SirItem.key_map( @sir_entries )
      @out_order.map!{ |e| @key_map[ e ]}
    end
  end

  # GET /sii/1/all

  def show_all
  end

  # GET /sil/1/sii/new

  def new
    @sir_item = SirItem.new
    @sir_item.sir_log = @sir_log
    set_selections( :to_create )
  end

  # GET /sii/1/edit

  def edit
    @sir_log = @sir_item.sir_log
    set_selections( :to_update )
  end

  # POST /sii
 
  def create
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
    end

    def set_sir_item
      @sir_item = SirItem.find( params[ :id ])
    end

    def set_selections( action )
      pg = current_user.permitted_groups( feature_identifier, action )
      @sir_groups = Group.permitted_groups( pg ).active_only.participants_only.collect{ |g| [ g.code_and_label, g.id ]}
      @sir_phases = PhaseCode.all.order( :code ).collect{ |p| [ p.code_and_label, p.id ]}
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def sir_item_params
      params.require( :sir_item ).permit( :sir_log_id,
        :group_id, :reference, :cfr_record_id, :label, :status,
        :category, :phase_code_id, :archived, :description )
    end
end
