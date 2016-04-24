class PcpSubjectsController < ApplicationController
  before_action :set_pcp_subject,  only: [ :show, :edit, :info, :update, :destroy, :update_release, :show_release ]
  before_action :set_selections,   only: [ :edit, :new, :update ]
  before_action :set_valid_params, only: [ :edit, :new, :update, :create,  ]

  initialize_feature FEATURE_ID_PCP_SUBJECTS, FEATURE_ACCESS_INDEX, FEATURE_CONTROL_CUG

# GET /ors

  def index
    @pcp_subjects = PcpSubject.includes( :pcp_steps ).all_active.paginate( page: params[ :page ])
  end

  # GET /pcs/1

  def show
  end

  # GET /pcs/1/info - history

  def info
    set_final_breadcrumb( :history )
  end

  # GET /pcs/1/show_release/1

  def show_release
    @pcp_step = @pcp_subject.pcp_steps.where( step_no: params[ :step_no ]).first
    if @pcp_step then
      render :reldoc, layout: 'plain_print'
    else
    end
  end

  # GET /pcs/new

  def new
    @pcp_subject = PcpSubject.new
  end

  # GET /pcs/1/edit

  def edit
  end

  # POST /pcs

  def create
    @pcp_subject = PcpSubject.new( pcp_subject_params )
    @pcp_step = @pcp_subject.pcp_steps.build
    respond_to do |format|
      if @pcp_subject.save then
        format.html { redirect_to @pcp_subject, notice: I18n.t( 'pcp_subjects.msg.new_ok' )}
      else
        set_selections
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /pcs/1

  def update
    respond_to do |format|
      if @pcp_subject.update( pcp_subject_params )
        format.html { redirect_to @pcp_subject, notice: I18n.t( 'pcp_subjects.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # GET /pcs/1/release

  def update_release
    if @pcp_subject.user_is_owner_or_deputy?( current_user.id, @pcp_step.acting_group_switch )
      respond_to do |format|
        case @pcp_step.release_type
        when 0
          set_final_breadcrumb( :release )
          @pcp_step_new = @pcp_subject.pcp_steps.create
          @pcp_step_new.create_release_from( @pcp_step, current_user )
          PcpStep.transaction do
            if @pcp_step_new.save && @pcp_step.save then
              format.html { redirect_to action: :show_release, id: @pcp_subject.id, step_no: @pcp_step_new.step_no, notice: I18n.t( 'pcp_subjects.msg.release_ok' )}
            else
              format.html { render :show }
            end
          end
        when 1
          set_final_breadcrumb( :release )
          @pcp_step.set_release_data( current_user )
          if @pcp_step.save then
            format.html
#            format.html { redirect_to @pcp_subject, notice: I18n.t( 'pcp_subjects.msg.release_ok' )}
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
      @pcp_step = @pcp_subject.current_step
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def pcp_subject_params
        params.require( :pcp_subject ).permit( @valid_subject_params << { pcp_steps_attributes: @valid_step_params })
    end

    # define list of parameters which can be modified

    def set_valid_params
      if @pcp_subject.nil? || @pcp_subject.id.nil? then
        # assume new/create
        @valid_step_params = []
        @valid_subject_params = [ :pcp_category_id, :title, :note, :project_doc_id, :report_doc_id ]
      else
        if @pcp_step.in_presenting_group? then
          if @pcp_step.status_closed? then
            @valid_step_params = []
            @valid_subject_params = [ :archived ]
          else
            @valid_step_params = [ :id, :subject_version, :note, :subject_date, :due_date ]
            @valid_subject_params = [ :pcp_category_id, :title, :note, :project_doc_id, :report_doc_id, :p_group_id, :p_owner_id, :p_deputy_id ]
          end
        else
          @valid_step_params = [ :id, :note, :due_date, :new_assmt ]
          @valid_subject_params = [ :c_group_id, :c_owner_id, :c_deputy_id ]
        end
      end
    end

    # retrieve groups for drop-down list box

    def set_selections
      @group_selection = Group.active_only.participants_only.collect{ |g| [ g.code_and_label, g.id ]}
      @pcp_categories = PcpCategory.all.collect{ |c| [ c.label, c.id ]}
    end

end
