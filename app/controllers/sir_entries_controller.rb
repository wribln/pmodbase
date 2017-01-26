class SirEntriesController < ApplicationController
  before_action :set_sir_entry, only: [:show, :edit, :update, :destroy]

  # GET /sir_entries
  # GET /sir_entries.json
  def index
    @sir_entries = SirEntry.all
  end

  # GET /sir_entries/1
  # GET /sir_entries/1.json
  def show
  end

  # GET /sir_entries/new
  def new
    @sir_entry = SirEntry.new
  end

  # GET /sir_entries/1/edit
  def edit
  end

  # POST /sir_entries
  # POST /sir_entries.json
  def create
    @sir_entry = SirEntry.new(sir_entry_params)

    respond_to do |format|
      if @sir_entry.save
        format.html { redirect_to @sir_entry, notice: 'Sir entry was successfully created.' }
        format.json { render :show, status: :created, location: @sir_entry }
      else
        format.html { render :new }
        format.json { render json: @sir_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sir_entries/1
  # PATCH/PUT /sir_entries/1.json
  def update
    respond_to do |format|
      if @sir_entry.update(sir_entry_params)
        format.html { redirect_to @sir_entry, notice: 'Sir entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @sir_entry }
      else
        format.html { render :edit }
        format.json { render json: @sir_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sir_entries/1
  # DELETE /sir_entries/1.json
  def destroy
    @sir_entry.destroy
    respond_to do |format|
      format.html { redirect_to sir_entries_url, notice: 'Sir entry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sir_entry
      @sir_entry = SirEntry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sir_entry_params
      params.require(:sir_entry).permit(:sir_item_id, :type, :group_id, :due_date, :parent_id, :no_sub_req, :desc)
    end
end
