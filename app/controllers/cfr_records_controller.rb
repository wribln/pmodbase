class CfrRecordsController < ApplicationController

  initialize_feature FEATURE_ID_CFR_RECORDS, FEATURE_ACCESS_INDEX, FEATURE_CONTROL_GRP 
  before_action :set_cfr_record, only: [ :show, :show_view, :edit, :update, :destroy ]
  before_action :set_file_types, only: [ :index, :edit, :new, :update ]

  # GET /cfr

  def index
    @filter_fields = filter_params
    @filter_groups = permitted_groups( :to_index )
    @cfr_records = CfrRecord.filter( @filter_fields ).all_permitted( current_user ).includes( :cfr_locations ).paginate( page: params[ :page ])
  end

  # GET /cfr/id/view

  def show_view
    render_no_permission unless has_access?( :to_read )
  end

  # GET /cfr/id

  def show
    render_no_permission unless has_access?( :to_read )
  end

  # GET /cfr/new
  #
  # one cfr record + one

  def new
    @cfr_record = CfrRecord.new
    @cfr_location = @cfr_record.cfr_locations.new
    @cfr_groups = permitted_groups( :to_create )
  end

  # GET /cfr/1/edit

  def edit
    if has_access?( :to_update )
      @cfr_groups = permitted_groups( :to_update )
    else
      render_no_permission
    end
  end

  # POST /cfr

  def create
    @cfr_record = CfrRecord.new( cfr_record_params )
    if has_access?( :to_create )
      respond_to do |format|
        if params[ :commit ] == I18n.t( 'button_label.defaults' ) then
          set_defaults
        elsif @cfr_record.save then
          @cfr_record.update_main_location
          format.html { redirect_to @cfr_record, notice: I18n.t( 'cfr_records.msg.create_ok' )}
          next
        end
        set_file_types
        @cfr_groups = permitted_groups( :to_create )
        format.html { render :new }
      end
    else
      render_no_permission
    end
  end

  # PATCH/PUT /cfr/1

  def update
    if has_access?( :to_update )
      respond_to do |format|
        params[ :cfr_record ][ :cfr_locations_attributes ].try( :delete, 'template' )
        cfr_params = cfr_record_params
        @cfr_record.assign_attributes( cfr_params ) unless cfr_params.empty?
        if params[ :commit ] == I18n.t( 'button_label.defaults' ) then
          set_defaults
        elsif @cfr_record.save then
          format.html { redirect_to @cfr_record, notice: I18n.t( 'cfr_records.msg.update_ok' )}
          next
        end
        set_file_types
        @cfr_groups = permitted_groups( :to_update )
        format.html { render :edit }
      end
    else
      render_no_permission
    end
  end

  # DELETE /cfr/1

  def destroy
    if has_access?( :to_delete )
      @cfr_record.destroy
      respond_to do |format|
        format.html { redirect_to cfr_records_url, notice: I18n.t( 'cfr_records.msg.delete_ok' )}
      end
    else
      render_no_permission
    end
  end

  private

    # set defaults when requested

    def set_defaults
      @cfr_record.set_blank_default( :doc_owner, current_user.account_info )
      ml = @cfr_record.cfr_locations.find{ |l| l.is_main_location }
      @cfr_record.cfr_locations.each { | l | l.set_defaults }
      fn = ml.try( :file_name ) # cannot assume that ml is set / valid
      @cfr_record.set_blank_default( :extension, CfrLocationType.get_extension( fn ))
      @cfr_record.set_blank_default( :cfr_file_type_id, CfrFileType.get_file_type( @cfr_record.extension ).try( :id ))
      @cfr_record.set_blank_default( :title, CfrLocationType.get_file_name( fn, @cfr_record.extension ))
      flash.notice = I18n.t( 'cfr_records.msg.defaults_set' )
      flash.discard
    end

    # Use callbacks to share common setup or constraints between actions.

    def set_cfr_record
      @cfr_record = CfrRecord.includes( :cfr_locations ).find( params[ :id ])
    end

    def has_access?( to_x )
      current_user.permission_to_access( feature_identifier, to_x, @cfr_record.group_id ) >= @cfr_record.conf_level
    end

    def set_file_types
      @cfr_file_types = CfrFileType.all.collect{ |ft| [ ft.label, ft.id ]}
    end

    # Never trust parameters from the scary internet, only allow the white list through

    def cfr_record_params
      params.require( :cfr_record ).permit( 
        :title, :note, :group_id, :conf_level, :doc_version, :doc_date, :doc_owner,
        :extension, :cfr_file_type_id, :hash_value, :hash_function,
        cfr_locations_attributes: [ :id, :_destroy,
          :cfr_location_type_id, :file_name, :doc_code, :doc_version, :uri, :is_main_location ])
    end

    def filter_params
      params.slice( :ff_id, :ff_text, :ff_type, :ff_grp ).clean_up
    end

    # Prepare a list of permitted groups

    def permitted_groups( action )
      pg = current_user.permitted_groups( feature_identifier, action )
      Group.permitted_groups( pg ).all.collect{ |g| [ g.code, g.id ]}
    end

end
