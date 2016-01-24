class AbbrSearchController < ApplicationController
  initialize_feature FEATURE_ID_ABBR_SEARCH, FEATURE_ACCESS_INDEX

  # GET /

  def index
    set_final_breadcrumb( nil )
    @filter_fields = filter_params
    if @filter_fields.empty?
      @abbreviations = Abbreviation.none
      @glossary_items = GlossaryItem.none
      @standards_bodies = StandardsBody.none
      @phase_codes = PhaseCode.none
      @groups = Group.none
      @country_names = CountryName.none
      @region_names = RegionName.none
      @unit_names = UnitName.none
      @total_rows = -1
    else
      @abbreviations = Abbreviation.filter( filter_params )
      @glossary_items = GlossaryItem.filter( filter_params )
      @standards_bodies = StandardsBody.filter( filter_params )
      @phase_codes = PhaseCode.filter( filter_params )
      @groups = Group.filter( filter_params )
      @country_names = CountryName.filter( filter_params )
      @region_names = RegionName.filter( filter_params )
      @unit_names = UnitName.filter( filter_params )
      @total_rows = 
        @abbreviations.length +
        @glossary_items.length +
        @standards_bodies.length +
        @phase_codes.length +
        @groups.length +
        @country_names.length +
        @region_names.length +
        @unit_names.length
    end
  end

private

  def filter_params
    params.slice( :as_abbr, :as_desc ).clean_up
  end

end
