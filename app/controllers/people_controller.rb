class PeopleController < ApplicationController
  initialize_feature FEATURE_ID_PEOPLE, FEATURE_ACCESS_SOME
  before_action :set_person, only: [ :show, :edit, :update, :destroy ]
  before_action :set_address_options, only: [ :edit, :create, :update ]

  # GET /people

  def index
    @people = Person.all.paginate( page: params[ :page ])
  end

  # GET /people/1

  def show
  end

  # GET /people/new

  def new
    @person = Person.new
  end

  # GET /people/1/edit
  
  def edit
  end

  # POST /people
  # - return to action edit to add contact information records

  def create
    @person = Person.new( person_params )
    respond_to do |format|
      if @person.save
        format.html { render :edit, notice: t( 'people.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /people/1
  # - remove 'template' from returned parameters because non-numeric
  #   hash-keys there cause "Unpermitted parameters" errors and prohibit
  #   saving any permission records (RoR 4.1.6)
  # - Note: 'template' entry may not exist in test environment, hence try
  #   is inserted
  
  def update
    respond_to do |format|
      params[:person][:contact_infos_attributes].try( :delete, 'template' )
      if @person.update( person_params )
        format.html { redirect_to @person, notice: t( 'people.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /people/1

  def destroy
    @person.destroy
    respond_to do |format|
      format.html { redirect_to people_url, notice: t( 'people.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_person
      @person = Person.includes( :contact_infos ).find( params[:id] )
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def person_params
      params.require( :person ).permit( :formal_name, :informal_name, :email, :involved,
        contact_infos_attributes: [ :id, :_destroy, :info_type, :phone_no_fixed,
                                    :phone_no_mobile, :department, :detail_location,
                                    :address_id ]
                                    )
    end

    def set_address_options
      @address_options = Address.all.map{ |a| [ a.label, a.id ]}
    end

end
