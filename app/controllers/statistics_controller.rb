class StatisticsController < ApplicationController
  initialize_feature FEATURE_ID_DBSTATS, FEATURE_ACCESS_SOME

  def index
    set_final_breadcrumb( nil )
    @statistics = Array.new
    @statistics << Abbreviation.get_stats
    @statistics << Account.get_stats
    @statistics << Address.get_stats
    @statistics << ContactInfo.get_stats
    @statistics << CountryName.get_stats
    @statistics << DbChangeRequest.get_stats
    @statistics << DccCode.get_stats
    @statistics << DsrStatusRecord.get_stats
    @statistics << DsrSubmission.get_stats
    @statistics << Feature.get_stats
    @statistics << FeatureCategory.get_stats
    @statistics << FunctionCode.get_stats
    @statistics << GlossaryItem.get_stats
    @statistics << Group.get_stats
    @statistics << GroupCategory.get_stats
    @statistics << Holiday.get_stats
    @statistics << Permission4Group.get_stats
    @statistics << Permission4Flow.get_stats
    @statistics << Person.get_stats
    @statistics << PhaseCode.get_stats
    @statistics << RegionName.get_stats
    @statistics << Responsibility.get_stats
    @statistics << RfcDocument.get_stats
    @statistics << RfcStatusRecord.get_stats
    @statistics << ServiceCode.get_stats
    @statistics << SiemensPhase.get_stats
    @statistics << StandardsBody.get_stats
    @statistics << SubmissionGroup.get_stats
    @statistics << UnitName.get_stats
    @statistics << WebLink.get_stats
  end
  
end
