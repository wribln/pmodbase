class GlossaryItemsController < ApplicationController
  require 'csv'
  include ControllerMethods

  initialize_feature FEATURE_ID_GLOSSARY, FEATURE_ACCESS_VIEW

  before_action :set_glossary_item, only: [ :show, :edit, :update, :destroy ]

  # GET /glossary

  def index
    @filter_fields = filter_params
    respond_to do |format|
      format.html do
        @glossary_items = GlossaryItem.filter( filter_params ).paginate( page: params[ :page ])
      end
      format.xls do # do not use pagination for CSV format
        @glossary_items = GlossaryItem.filter( filter_params )
        set_header( :xls, 'glossary.csv' )
      end
    end
  end

  # GET /glossary_items/1

  def show
  end

  # GET /glossary_items/new

  def new
    @glossary_item = GlossaryItem.new
  end

  # GET /glossary_items/1/edit

  def edit
  end

  # POST /glossary_items

  def create
    @glossary_item = GlossaryItem.new( glossary_item_params )

    respond_to do |format|
      if @glossary_item.save
        format.html { redirect_to @glossary_item, notice: t( 'glossary_items.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /glossary_items/1

  def update
    respond_to do |format|
      if @glossary_item.update(glossary_item_params)
        format.html { redirect_to @glossary_item, notice: t( 'glossary_items.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /glossary_items/1

  def destroy
    @glossary_item.destroy
    respond_to do |format|
      format.html { redirect_to glossary_items_url, notice: t( 'glossary_items.msg.delete_ok' ) }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_glossary_item
      @glossary_item = GlossaryItem.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def glossary_item_params
      params.require( :glossary_item ).permit( :term, :code, :description, :cfr_record_id )
    end

    def filter_params
      params.slice( :ff_id, :ff_term, :ff_code, :ff_desc, :ff_ref ).clean_up
    end

end
