class PcpItemsController < ApplicationController
  include ControllerMethods

  initialize_feature FEATURE_ID_PCP_ITEMS, FEATURE_ACCESS_VIEW + FEATURE_ACCESS_NDA, FEATURE_CONTROL_CUG

  before_action :set_pcp_subject, only: [ :index, :create, :new ]
  before_action :set_pcp_item, only: [ :show, :edit, :update, :destroy ]
  before_action :set_breadcrumb

  # GET /pcs/:pcp_subject_id/pci

  def index
    set_breadcrumb_path( pcp_subject_pcp_items_path( params[ :pcp_subject_id ]))
    @filter_fields = filter_params
    @pcp_items = @pcp_subject.pcp_items.filter( filter_params ).paginate( page: params[ :page ])
  end

  # GET /pci/1

  def show
    set_breadcrumb_path( pcp_subject_pcp_items_path( @pcp_item.pcp_subject ))
  end

  # GET /pci/:pcp_subject_id/pci/new

  def new
    set_breadcrumb_path( pcp_subject_pcp_items_path( params[ :pcp_subject_id ]))
    @pcp_item = @pcp_subject.pcp_items.new
    @pcp_item.pcp_step_id = @pcp_step.id
    @pcp_item.set_next_seqno
  end

  # GET /pci/1/edit

  def edit
    set_breadcrumb_path( pcp_subject_pcp_items_path( @pcp_item.pcp_subject ))
  end

  # POST /pci/:pcp_subject_id/pci

  def create
    @pcp_item =  @pcp_subject.pcp_items.new( pcp_item_params )
    respond_to do |format|
      @pcp_item.transaction do
        @pcp_item.pcp_step_id = @pcp_step.id
        @pcp_item.set_next_seqno
        if @pcp_item.save
          format.html { redirect_to @pcp_item, notice: t( 'pcp_items.msg.new_ok' )}
        else
          format.html { render :new }
        end
      end
    end
  end

  # PATCH/PUT /pci/1

  def update
    respond_to do |format|
      if @pcp_item.update( pcp_item_params )
        format.html { redirect_to @pcp_item, notice: t( 'pcp_items.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /pci/1

  def destroy
    @pcp_item.destroy
    respond_to do |format|
      format.html { redirect_to pcp_subject_pcp_items_path( @pcp_subject ), notice: t( 'pcp_items.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_pcp_subject
      @pcp_subject = PcpSubject.find( params[ :pcp_subject_id ])
      @pcp_step = @pcp_subject.current_steps.first
    end

    def set_pcp_item
      @pcp_item = PcpItem.find( params[ :id ])
      @pcp_subject = @pcp_item.pcp_subject
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def pcp_item_params
      params.require( :pcp_item ).permit( :reference, :description )
    end

    def filter_params
      params.slice( :ff_seqno, :ff_refs, :ff_desc, :ff_status ).clean_up
    end

    # fix breadcrumb to show parent

    def set_breadcrumb
      parent_breadcrumb( :pcp_subjects, pcp_subjects_path )
    end

end
