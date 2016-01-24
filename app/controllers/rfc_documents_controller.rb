class RfcDocumentsController < ApplicationController
  initialize_feature FEATURE_ID_RFC_DOCUMENTS, FEATURE_ACCESS_SOME
  before_action :set_rfc_document,  only: [ :show, :edit, :update, :destroy ]
  before_action :set_rfc_documents, only: [ :index ]

  # GET /rfc_documents

  def index
    @filter_fields = filter_params
  end

  # GET /rfc_documents/1

  def show
  end

  # GET /rfc_documents/new

  def new
    @rfc_document = RfcDocument.new
    @rfc_document.account_id = current_user.id
  end

  # GET /rfc_documents/1/edit

  def edit
  end

  # POST /rfc_documents

  def create
    @rfc_document = RfcDocument.new( rfc_document_params )
    @rfc_document.account_id = current_user.id
    respond_to do |format|
      if @rfc_document.save
        format.html { redirect_to @rfc_document, notice: t( 'rfc_documents.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /rfc_documents/1

  def update
    respond_to do |format|
      if @rfc_document.update( rfc_document_params )
        format.html { redirect_to @rfc_document, notice: t( 'rfc_documents.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /rfc_documents/1

  def destroy
    @rfc_document.destroy
    respond_to do |format|
      format.html { redirect_to rfc_documents_url, notice: t( 'rfc_documents.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_rfc_document
      @rfc_document = RfcDocument.find( params[ :id ])
    end

    def set_rfc_documents
      @rfc_documents = RfcDocument.filter( filter_params ).paginate( page: params[ :page ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def rfc_document_params
      params.require( :rfc_document ).permit( :question, :answer, :note, :rfc_status_record_id, :version )
    end

    def filter_params
      params.slice( :ff_srec ).clean_up
    end

end
