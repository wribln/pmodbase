# This controller handles all PCP Subjects available in the system.
# Access to all PCP Subjects is by groups, i.e. access to a specific
# group permits access to all PCP Subjects in which the user is either
# member of the Presenting or the Commenting Group.
#
# This controller is any user which should have read access to 
# PCP Subjects for his (or all) groups.
#
# Links from the PCP Subjects go to the PcpMySubjectsController for
# ease of handling. An additional access check will be performed there.

class PcpAllSubjectsController < ApplicationController

  initialize_feature FEATURE_ID_ALL_PCP_SUBJECTS, FEATURE_ACCESS_SOME, FEATURE_CONTROL_GRP

  before_action :set_pcp_subject,       only: [ :show, :edit, :destroy ]
  before_action :render_no_permission,  only: [ :create, :update ]

  def index
    @filter_fields = filter_params
    @filter_groups = permitted_groups_list( :to_index )
    @pcp_subjects = PcpSubject.filter( @filter_fields ).all_active.permitted_groups( current_user, :to_index ).paginate( page: params[ :page ])
  end

  def show
    most_recent_steps = @pcp_subject.current_steps
    @pcp_curr_step = most_recent_steps[ 0 ]
    @pcp_prev_step = most_recent_steps[ 1 ]
  end

  def stats
    # first see which groups can be viewed:
    pg = current_user.permitted_groups( FEATURE_ID_ALL_PCP_SUBJECTS, :to_index )
    case pg
    when nil
      grps = '1=0'
      @pcp_sub_title = '.sub_title_0'
    when ''
      grps = '1=1'
      @pcp_sub_title = '.sub_title_1'
    else
      grps = "p_group_id IN (#{ pg }) OR c_group_id IN (#{ pg })"
      @pcp_sub_title = '.sub_title_0'
    end

    # now determine all subjects by status:
    # s1a: last released PCP Step per PCP Subject
    # s1b: retrieve PCP Subject and status using s1a
    # s2: retrieve counts per PCP Category from PCP Subject using s1b
    # use LEFT JOIN so I get all PCP Subjects without a release to be
    # treated as 'new' (0)

    s1a = PcpStep.where.not( released_at: nil ).select( "pcp_subject_id AS a_pcp_subject_id, MAX( step_no ) AS a_step_no" ).group( :pcp_subject_id ).to_sql
    s1b = PcpStep.select( :pcp_subject_id, :subject_status ).joins( "INNER JOIN (#{ s1a }) s1a ON \"pcp_subject_id\" = \"a_pcp_subject_id\" AND \"step_no\" = \"a_step_no\"").to_sql
    s2 = PcpSubject.connection.select_rows( "SELECT pcp_category_id, subject_status, COUNT(*) FROM pcp_subjects LEFT JOIN (#{ s1b }) s1b ON id = pcp_subject_id WHERE (#{ grps }) GROUP BY subject_status" )
    @pcp_stats = PcpCategory.select( :id, :label ).order( :label ).pluck( :id, :label )

    # now I have in s2 an array of the resulting records, and
    # @pcp_stats an array of the subjects: create summary and detail records
    
    @pcp_totals = Array.new( 4, 0 )
    @pcp_stats.map!{ |r| r.concat Array.new( 4, 0 )}
    s2.each{ |c| @pcp_stats.assoc( c[ 0 ])[( c[ 1 ]|| 0 ) + 2 ] += c[ 2 ] }
    @pcp_stats.each do |r|
      r[ 5 ] = r[ 2..4 ].reduce(:+)
      @pcp_totals.collect!.with_index{ |t,i| t + r[ i + 2 ]}
    end
 end

  # redirect to PcpSubjectsController

  def new
    redirect_to new_pcp_subject_path, status: :see_other
  end

  def edit
    redirect_to edit_pcp_subject_path( @pcp_subject ), status: :see_other
  end

  def destroy
    redirect_to "/pcs/#{ @pcp_subject.id }", status: :see_other
  end

  # no permission (redirect does not make sense)

  def create
  end

  def update
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_pcp_subject
      @pcp_subject = PcpSubject.find( params[ :id ])
    end

    # prepare list of groups for selections

    def permitted_groups_list( action )
      pg = current_user.permitted_groups( FEATURE_ID_ALL_PCP_SUBJECTS, action )
      Group.permitted_groups( pg ).all.collect{ |g| [ g.code, g.id ]}
    end

    # prepare parameters for filtering

    def filter_params
      params.slice( :ff_id, :ff_titl, :ff_igrp, :ff_note ).clean_up
    end


end
