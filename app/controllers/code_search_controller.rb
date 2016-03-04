class CodeSearchController < ApplicationController
  initialize_feature FEATURE_ID_CODE_SEARCH, FEATURE_ACCESS_INDEX

  # GET /

  def index
    set_final_breadcrumb( nil )
    @filter_fields = filter_params
    @code_first_char = @filter_fields.has_key?( :as_code ) && @filter_fields[ :as_code ].chr
    # preset results
    @function_codes = FunctionCode.none
    @service_codes = ServiceCode.none
    @product_codes = ProductCode.none
    @location_codes = LocationCode.none
    @phase_codes = PhaseCode.none
    @groups = Group.none
    case @code_first_char
    when FunctionCode.code_prefix
      @function_codes = FunctionCode.filter( @filter_fields )
    when ServiceCode.code_prefix
      @service_codes = ServiceCode.filter( @filter_fields )
    when ProductCode.code_prefix
      @product_codes = ProductCode.filter( @filter_fields )
    when LocationCode.code_prefix
      @location_codes = LocationCode.filter( @filter_fields )
    when PhaseCode.code_prefix
      @phase_codes = PhaseCode.filter( @filter_fields )
    when '(',')' # prefix for source/destination codes
      @filter_fields[ :as_code ] = @filter_fields[ :as_code ][ 1..-1 ]
      @groups = Group.filter( @filter_fields )
    else
      unless @filter_fields.empty? then
        @function_codes = FunctionCode.filter( @filter_fields )
        @service_codes = ServiceCode.filter( @filter_fields )
        @product_codes = ProductCode.filter( @filter_fields )
        @location_codes = LocationCode.filter( @filter_fields )
        @phase_codes = PhaseCode.filter( @filter_fields )
        @groups = Group.filter( @filter_fields )
      end
    end
    # how many rows to display?
    @total_rows = 
      if @filter_fields.empty?
        -1
      else
        @function_codes.length +
        @service_codes.length +
        @product_codes.length +
        @location_codes.length +
        @phase_codes.length +
        @groups.length
      end
  end

private

  def filter_params
    params.slice( :as_code, :as_desc ).clean_up
  end

end
