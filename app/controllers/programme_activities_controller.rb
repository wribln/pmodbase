class ProgrammeActivitiesController < ApplicationController
  initialize_feature FEATURE_ID_ACTIVITIES, FEATURE_ACCESS_VIEW

  before_action :set_programme_activity, only: [:show, :edit, :update, :destroy]

  # GET /ppas

  def index
    @programme_activities = ProgrammeActivity.all
  end

  # GET /ppas/1

  def show
  end

  # GET /ppas/new

  def new
    @programme_activity = ProgrammeActivity.new
  end

  # GET /ppas/1/edit

  def edit
  end

  # POST /ppas

  def create
    @programme_activity = ProgrammeActivity.new(programme_activity_params)

    respond_to do |format|
      if @programme_activity.save
        format.html { redirect_to @programme_activity, notice: 'Programme activity was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /ppas/1

  def update
    respond_to do |format|
      if @programme_activity.update(programme_activity_params)
        format.html { redirect_to @programme_activity, notice: 'Programme activity was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /ppas/1

  def destroy
    @programme_activity.destroy
    respond_to do |format|
      format.html { redirect_to programme_activities_url, notice: 'Programme activity was successfully destroyed.' }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_programme_activity
      @programme_activity = ProgrammeActivity.find( params[:id] )
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def programme_activity_params
      params.require( :programme_activity ).permit( :project_id, :activity_id, :activity_label, :start_date, :finish_date )
    end

end
