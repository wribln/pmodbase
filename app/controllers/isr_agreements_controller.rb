# The purpose of this controller is to display an index of all interface agreements:
# All interface agreements will be shown - including all inactive (withdrawn, terminatted, etc.)
# This controller shall also display any statistics based on interface agreements.

require 'isr_work_flow.rb'
require 'csv'

class IsrAgreementsController < ApplicationController
  include IsrWorkFlow
  include ControllerMethods


  initialize_feature FEATURE_ID_ISR_AGREEMENTS, FEATURE_ACCESS_SOME

  # GET /isa

  def index 
    set_workflow # for labels
    @filter_fields = filter_params
    @filter_states = @workflow.all_states_for_select
    @filter_groups = Group.active_only.participants_only.collect{ |g| [ g.code, g.id ]}
    @isr_agreements = IsrAgreement.filter( @filter_fields ).all.paginate( page: params[ :page ])
  end

  # GET /isa/stats

  def show_stats
    @if_stats = IsrInterface.unscoped.group( :if_status ).count
    @if_total = @if_stats.values.inject( :+ )

    @if_freq = ActiveRecord::Base.connection.exec_query( 'SELECT ia_nos, COUNT(*), SUM(ia_nos) FROM (SELECT DISTINCT COUNT(ia_no) AS ia_nos, isr_interface_id AS id_s FROM "isr_agreements" GROUP BY id_s ) GROUP BY ia_nos' )
    @if_count = @if_freq.rows.sum{ |e| e[ 1 ]}
    @ia_count = @if_freq.rows.sum{ |e| e[ 2 ]}

    @ia_stats = IsrAgreement.unscoped.group( :ia_status ).count
    @ia_active = @ia_closed = @ia_inactive = @ia_pending = 0
    @ia_stats.each_pair do |k,v|
      case k
      when *IsrAgreement::ISR_IA_STATUS_ACTIVE
        @ia_active += v
      when *IsrAgreement::ISR_IA_STATUS_CLOSED
        @ia_closed += v
      when *IsrAgreement::ISR_IA_STATUS_INACTIVE
        @ia_inactive += v
      when *IsrAgreement::ISR_IA_STATUS_PENDING
        @ia_pending += v
      end
    end
    @ia_total = @ia_active + @ia_closed
    @ia_stats.default = 0
    respond_to do |format|
      format.html
      format.xls do
        @if_stats.default = 0 # output zeros for nil values
        set_header( :xls, 'ia_stats.csv' )
      end
    end
  end

  private

    def filter_params
      params.slice( :ff_id, :ff_sts, :ff_grp, :ff_txt, :ff_wfs ).clean_up
    end

end
