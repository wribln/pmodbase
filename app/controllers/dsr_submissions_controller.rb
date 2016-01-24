class DsrSubmissionsController < ApplicationController
  initialize_feature FEATURE_ID_DSR_SUBMISSIONS, FEATURE_ACCESS_SOME
  before_action :set_dsr_submission, only: [ :show, :edit, :update, :destroy ]
  before_action :set_dsr_submissions, only: [ :index ]

  # GET /dsbs

  def index
    @filter_fields = filter_params
  end

  # GET /dsbs/1

  def show
  end

  # GET /dsbs/new

  def new
    @dsr_submission = DsrSubmission.new
  end

  # GET /dsbs/1/edit

  def edit
  end

  # POST /dsb
  
  def create
    @dsr_submission = DsrSubmission.new( dsr_submission_params )
    respond_to do |format|
      if @dsr_submission.save
        format.html { redirect_to @dsr_submission, notice: t( 'dsr_submissions.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /dsbs/1

  def update
    respond_to do |format|
      if @dsr_submission.update(dsr_submission_params)
        format.html { redirect_to @dsr_submission, notice: t( 'dsr_submissions.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /dsbs/1

  def destroy
    @dsr_submission.destroy
    respond_to do |format|
      format.html { redirect_to dsr_submissions_url, notice: t( 'dsr_submissions.msg.delete_ok' )}
    end
  end

  private

    def set_dsr_submission
      @dsr_submission = DsrSubmission.includes( :dsr_status_record ).find( params[ :id ])
    end

    def set_dsr_submissions
      @dsr_submissions = DsrSubmission.default_order.filter( filter_params ).paginate( page: params[ :page ])
    end

    def filter_params
      params.slice( :ff_dsr, :ff_sdoc, :ff_rdoc, :ff_sdat, :ff_rdat, :ff_stat ).clean_up
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def dsr_submission_params
      params.require( :dsr_submission ).permit( 
        :dsr_status_record_id,
        :submission_no,
        :sender_doc_id_version,
        :project_doc_id_version,
        :receiver_doc_id_version,
        :submission_receiver_doc_id,
        :submission_project_doc_id,
        :response_sender_doc_id,
        :response_project_doc_id,
        :plnd_submission,
        :actl_submission,
        :xpcd_response,
        :xpcd_response_delta,
        :actl_response,
        :response_status )
    end
end
