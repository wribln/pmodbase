class ContactInfosController < ApplicationController
  initialize_feature FEATURE_ID_CONTACT_INFOS, FEATURE_ACCESS_SOME
  before_action :set_contact_info, only: [ :show, :edit, :update, :destroy ]
  before_action :set_address_options, only: [:edit, :update, :new, :create ]

  # GET /contact_infos

  def index
    @contact_infos = ContactInfo.all
  end

  # GET /contact_infos/1

  def show
  end

  # GET /contact_infos/new

  def new
    @contact_info = ContactInfo.new
  end

  # GET /contact_infos/1/edit

  def edit
  end

  # POST /contact_infos

  def create
    @contact_info = ContactInfo.new(contact_info_params)
    respond_to do |format|
      if @contact_info.save
        format.html { redirect_to @contact_info, notice: t( 'contact_infos.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /contact_infos/1

  def update
    respond_to do |format|
      if @contact_info.update(contact_info_params)
        format.html { redirect_to @contact_info, notice: t( 'contact_infos.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /contact_infos/1

  def destroy
    @contact_info.destroy
    respond_to do |format|
      format.html { redirect_to contact_infos_url, notice: t( 'contact_infos.msg.delete_ok' )}
    end
  end

  private
    
    # Use callbacks to share common setup or constraints between actions.
    
    def set_contact_info
      @contact_info = ContactInfo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def contact_info_params
      params.require(:contact_info).permit( :person_id, :info_type, :phone_no_fixed, :phone_no_mobile, :department, :detail_location, :address_id )
    end

    # prepare list of addresses

    def set_address_options
      @address_options = Address.all.map{ |a| [ a.label, a.id ]}
    end
    
end
