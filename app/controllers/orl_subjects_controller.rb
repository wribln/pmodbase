class OrlSubjectsController < ApplicationController
  before_action :set_orl_subject, only: [ :show, :edit, :update, :destroy ]
  before_action :set_selections,  only: [ :edit, :new, :update ]

  initialize_feature FEATURE_ID_ORL_SUBJECTS, FEATURE_ACCESS_INDEX, FEATURE_CONTROL_CUG

# GET /ors

  def index
    @orl_subjects = OrlSubject.includes( :orl_steps ).all_active.paginate( page: params[ :page ])
  end

  # GET /orl_subjects/1

  def show
  end

  # GET /orl_subjects/new

  def new
    @orl_subject = OrlSubject.new
  end

  # GET /orl_subjects/1/edit

  def edit
  end

  # POST /orl_subjects

  def create
    @orl_subject = OrlSubject.new( orl_subject_params )
    respond_to do |format|
      if @orl_subject.save
        format.html { redirect_to @orl_subject, notice: I18n.t( 'orl_subjects.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /orl_subjects/1

  def update
    respond_to do |format|
      if @orl_subject.update(orl_subject_params)
        format.html { redirect_to @orl_subject, notice: I18n.t( 'orl_subjects.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /orl_subjects/1

  def destroy
    @orl_subject.destroy
    respond_to do |format|
      format.html { redirect_to orl_subjects_url, notice: I18n.t( 'orl_subjects.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_orl_subject
      @orl_subject = OrlSubject.find( params[ :id ])
      @orl_step = @orl_subject.current_step
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def orl_subject_params
      params.require( :orl_subject ).permit(
        :orl_category_id, :desc, :note, :project_doc_id, :o_group_id, :r_group_id,
        :o_owner_id, :o_deputy_id, :r_owner_id, :r_deputy_id, :report_doc_id, :archived,
          :orl_steps_attributes[ :id, :subject_version, :note, :subject_date, :due_date, :subject_status, :assessment ])
    end

    # retrieve groups for drop-down list box

    def set_selections
      @group_selection = Group.active_only.participants_only.collect{ |g| [ g.code_and_label, g.id ]}
      @orl_categories = OrlCategory.all.collect{ |c| [ c.label, c.id ]}
    end

end
