class AccountsController < ApplicationController
  initialize_feature FEATURE_ID_ACCOUNTS_AND_PERMISSIONS, FEATURE_ACCESS_SOME
  before_action :set_account,  only: [ :show, :edit, :update, :destroy ]
  before_action :set_accounts, only: [ :index ]
  
  # GET /accounts
  
  def index
  end

  # GET /accounts/1

  def show
  end

  # GET /accounts/new

  def new
    @account = Account.new
  end

  # GET /accounts/1/edit

  def edit
  end

  # POST /accounts
  # - return to action edit to add permission records

  def create
    @account = Account.new( account_params )
    respond_to do |format|
      if @account.save
        format.html { render :edit, notice: t( 'accounts.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PUT /accounts/1
  # - remove "template" from returned parameters because non-numeric
  #   hash-keys there cause "Unpermitted parameters" errors and prohibit
  #   saving any permission records (RoR 4.1.6)
  
  def update
    respond_to do |format|
      params[:account][:permission4_groups_attributes].delete( 'template' )
      params[:account][:permission4_flows_attributes].delete( 'template' )
      if @account.update( account_params )
        format.html { redirect_to @account, notice: t( 'accounts.msg.edit_ok' )}
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /accounts/1
  
  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to accounts_url, notice: t( 'accounts.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_account
      @account = Account.includes( :person,
        permission4_groups: [ :feature, :group ],
        permission4_flows:  [ :feature ]).find( params[ :id ] )
    end

    def set_accounts
      @filter_fields = filter_params
      @accounts = Account.includes( :person ).filter( filter_params ).paginate( page: params[ :page ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def account_params
      params.require( :account ).permit(
          :name, :person_id, :password, :password_confirmation, :active, :keep_base_open,
        permission4_groups_attributes: [ :id, :feature_id, :group_id, :_destroy, 
                                  :to_index, :to_create, :to_read, :to_update, :to_delete ],
        permission4_flows_attributes:  [ :id, :feature_id, :workflow_id, :_destroy,
                                  :label, :tasklist ])
    end

    def filter_params
      params.slice( :ff_id, :ff_name, :ff_person_id, :ff_active ).clean_up
    end      

end
