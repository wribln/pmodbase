class ACodeSearchController < ApplicationController
  initialize_feature FEATURE_ID_A_CODE_SEARCH, FEATURE_ACCESS_VIEW

  # GET /

  def index
    set_final_breadcrumb( nil )
    @filter_fields = filter_params
    @code_first_char = @filter_fields.has_key?( :as_code ) && @filter_fields[ :as_code ].chr
    # preset results
    @a1_codes = A1Code.none
    @a2_codes = A2Code.none
    @a3_codes = A3Code.none
    @a4_codes = A4Code.none
    @a5_codes = A5Code.none
    @a6_codes = A6Code.none
    @a7_codes = A7Code.none
    @a8_codes = A8Code.none
    unless @filter_fields.empty? then
      @a1_codes = A1Code.filter( @filter_fields )
      @a2_codes = A2Code.filter( @filter_fields )
      @a3_codes = A3Code.filter( @filter_fields )
      @a4_codes = A4Code.filter( @filter_fields )
      @a5_codes = A5Code.filter( @filter_fields )
      @a6_codes = A6Code.filter( @filter_fields )
      @a7_codes = A7Code.filter( @filter_fields )
      @a8_codes = A8Code.filter( @filter_fields )
    end
    # how many rows to display?
    @total_rows = 
      if @filter_fields.empty?
        -1
      else
        @a1_codes.length +
        @a2_codes.length + 
        @a3_codes.length + 
        @a4_codes.length +
        @a5_codes.length +
        @a6_codes.length + 
        @a7_codes.length +
        @a8_codes.length
      end
  end

private

  def filter_params
    params.slice( :as_code, :as_desc ).clean_up
  end

end
