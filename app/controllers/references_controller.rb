class ReferencesController < ApplicationController
  require 'csv'
  include ControllerMethods

  initialize_feature FEATURE_ID_REFERENCES, FEATURE_ACCESS_VIEW

  before_action :set_reference, only: [:show, :edit, :update, :destroy]

  # GET /references
 
  def index
    @references = Reference.all
    respond_to do |format|
      format.html
      format.xls { set_header( :xls, 'references.csv' )}
    end
  end

  # GET /references/1

  def show
  end

  # GET /references/new

  def new
    @reference = Reference.new
  end

  # GET /references/1/edit

  def edit
  end

  # POST /references

  def create
    @reference = Reference.new(reference_params)
    respond_to do |format|
      if @reference.save
        format.html { redirect_to @reference, notice: t( 'references.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /references/1

  def update
    respond_to do |format|
      if @reference.update( reference_params )
        format.html { redirect_to @reference, notice: t( 'references.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /references/1

  def destroy
    @reference.destroy
    respond_to do |format|
      format.html { redirect_to references_url, notice: t( 'references.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
  
    def set_reference
      @reference = Reference.find( params[:id] )
    end

    # Never trust parameters from the scary internet, only allow the white list through.
  
    def reference_params
      params.require( :reference ).permit( :code, :description, :project_doc_id )
    end

end
