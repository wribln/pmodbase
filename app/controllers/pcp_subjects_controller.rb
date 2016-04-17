class PcpSubjectsController < ApplicationController
  before_action :set_pcp_subject, only: [ :show, :edit, :update, :destroy, :update_release ]
  before_action :set_selections,  only: [ :edit, :new, :update ]

  initialize_feature FEATURE_ID_PCP_SUBJECTS, FEATURE_ACCESS_INDEX, FEATURE_CONTROL_CUG

# GET /ors

  def index
    @pcp_subjects = PcpSubject.includes( :pcp_steps ).all_active.paginate( page: params[ :page ])
  end

  # GET /pcp_subjects/1

  def show
  end

  # GET /pcp_subjects/new

  def new
    @pcp_subject = PcpSubject.new
  end

  # GET /pcp_subjects/1/edit

  def edit
  end

  # POST /pcp_subjects

  def create
    @pcp_subject = PcpSubject.new( pcp_subject_params )
    @pcp_step = PcpStep.new( pcp_subject: @pcp_subject )
    respond_to do |format|
      if @pcp_subject.save
        format.html { redirect_to @pcp_subject, notice: I18n.t( 'pcp_subjects.msg.new_ok' )}
      else
        set_selections
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /pcp_subjects/1

  def update
    respond_to do |format|
      if @pcp_subject.update( pcp_subject_params )
        format.html { redirect_to @pcp_subject, notice: I18n.t( 'pcp_subjects.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  def update_release
    @pcp_step_new = PcpStep.new( @pcp_subject )
    @pcp_step_new.create_release_from( @pcp_step )
    if @pcp_step.save
      format.html { redirect_to @pcp_subject, notice: I18n.t( 'pcp_subjects.msg.release_ok' )}
    else
      format.html { render :edit }
    end
  end

  # DELETE /pcp_subjects/1

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
      case action_name
      when :create
        params.require( :pcp_subject ).permit(
          :pcp_category_id, :desc, :note, :project_doc_id, :report_doc_id )
      when :update
        params.require( :pcp_subject ).permit(
          :pcp_category_id, :desc, :note, :project_doc_id, :p_group_id, :c_group_id,
          :p_owner_id, :p_deputy_id, :c_owner_id, :c_deputy_id, :report_doc_id, :archived,
            :pcp_steps_attributes[ :id, :subject_version, :note, :subject_date, :due_date, :subject_status, :assessment ])
      end
    end

    # retrieve groups for drop-down list box

    def set_selections
      @group_selection = Group.active_only.participants_only.collect{ |g| [ g.code_and_label, g.id ]}
      @pcp_categories = PcpCategory.all.collect{ |c| [ c.label, c.id ]}
    end

end
