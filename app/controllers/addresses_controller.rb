class AddressesController < ApplicationController
  initialize_feature FEATURE_ID_ADDRESSES, FEATURE_ACCESS_VIEW
  before_action :set_address, only: [ :show, :edit, :update, :destroy ]
  before_action :set_addresses, only: [ :index ]

  # GET /addresses
  
  def index
    @filter_fields = filter_params
  end

  # GET /addresses/1
 
  def show
  end

  # GET /addresses/new

  def new
    @address = Address.new
  end

  # GET /addresses/1/edit

  def edit
  end

  # POST /addresses

  def create
    @address = Address.new(address_params)

    respond_to do |format|
      if @address.save
        format.html { redirect_to @address, notice: t( 'addresses.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /addresses/1

  def update
    respond_to do |format|
      if @address.update( address_params )
        format.html { redirect_to @address, notice: t( 'addresses.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /addresses/1

  def destroy
    @address.destroy
    respond_to do |format|
      format.html { redirect_to addresses_url, notice: t( 'addresses.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    
    def set_address
      @address = Address.find( params[ :id ])
    end

    def set_addresses
      @addresses = Address.order( :label ).filter( filter_params )
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def address_params
      params.require( :address ).permit( :label, :street_address, :postal_address )
    end

    def filter_params
      params.slice( :ff_id, :ff_label, :ff_address ).clean_up
    end
    
end
