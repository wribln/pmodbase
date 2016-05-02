class PcpCommentsController < ApplicationController
  before_action :set_pcp_comment, only: [:show, :edit, :update, :destroy]

  # GET /pcp_comments
  # GET /pcp_comments.json
  def index
    @pcp_comments = PcpComment.all
  end

  # GET /pcp_comments/1
  # GET /pcp_comments/1.json
  def show
  end

  # GET /pcp_comments/new
  def new
    @pcp_comment = PcpComment.new
  end

  # GET /pcp_comments/1/edit
  def edit
  end

  # POST /pcp_comments
  # POST /pcp_comments.json
  def create
    @pcp_comment = PcpComment.new(pcp_comment_params)

    respond_to do |format|
      if @pcp_comment.save
        format.html { redirect_to @pcp_comment, notice: 'Pcp comment was successfully created.' }
        format.json { render :show, status: :created, location: @pcp_comment }
      else
        format.html { render :new }
        format.json { render json: @pcp_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pcp_comments/1
  # PATCH/PUT /pcp_comments/1.json
  def update
    respond_to do |format|
      if @pcp_comment.update(pcp_comment_params)
        format.html { redirect_to @pcp_comment, notice: 'Pcp comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @pcp_comment }
      else
        format.html { render :edit }
        format.json { render json: @pcp_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pcp_comments/1
  # DELETE /pcp_comments/1.json
  def destroy
    @pcp_comment.destroy
    respond_to do |format|
      format.html { redirect_to pcp_comments_url, notice: 'Pcp comment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pcp_comment
      @pcp_comment = PcpComment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pcp_comment_params
      params.require(:pcp_comment).permit(:pcp_item_id, :pcp_step_id, :desc, :author, :public)
    end
end
