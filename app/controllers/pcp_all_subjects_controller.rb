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
    render plain: 'Not yet implemented.'
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
