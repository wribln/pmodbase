class CsrStatusRecordsController < ApplicationController
  initialize_feature FEATURE_ID_CSR_STATUS_RECORDS, FEATURE_ACCESS_VIEW
  before_action :set_csr_status_record, only: [ :show, :edit, :update, :destroy ]
  before_action :set_selections, only: [ :new, :edit, :create, :udpate, :index ]

  # GET /csrs

  def index
    @filter_fields = filter_params
    @csr_status_records = CsrStatusRecord.active.filter( filter_params ).paginate( page: params[ :page ])
  end

  # GET /csrs/show

  def show
  end

  # GET /csrs/new

  def new
    @csr_status_record = CsrStatusRecord.new
    @csr_status_record.correspondence_date = Date.today
  end

  # GET /csrs/1/edit

  def edit
  end

  # POST /csrs

  def create
    @csr_status_record = CsrStatusRecord.new( csr_status_record_params )
    respond_to do |format|
      if @csr_status_record.save
        format.html { redirect_to @csr_status_record, notice: t( 'csr_status_records.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /csrs/1

  def update
    respond_to do |format|
      if @csr_status_record.update(csr_status_record_params)
        format.html { redirect_to @csr_status_record, notice: t( 'csr_status_records.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /csrs/1

  def destroy
    @csr_status_record.destroy
    respond_to do |format|
      format.html { redirect_to csr_status_records_url, notice: t( 'csr_status_records.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
  
    def set_csr_status_record
      @csr_status_record = CsrStatusRecord.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def csr_status_record_params
      params.require( :csr_status_record ).permit(
        :correspondence_type,
        :transmission_type,
        :receiver_group_id,
        :sender_group_id,
        :sender_reference,
        :correspondence_date,
        :subject,
        :project_doc_id,
        :sender_doc_id,
        :classification,
        :plan_reply_date,
        :actual_reply_date,
        :reply_status_record_id,
        :status,
        :notes )
    end

    # prepare lists for selections

    def set_selections
      @all_groups = Group.participants_only.active_only
      @any_groups = Group.all
    end

    def filter_params
      params.slice( :ff_id, :ff_type, :ff_group, :ff_class, :ff_status, :ff_sub, :ff_note ).clean_up
    end

end
