require 'active_support/concern'
module PcpAssessmentModel
  extend ActiveSupport::Concern

  # provides common code for assessment of PCP Items and Comments

  included do

    validates :assessment,
      presence: true,
      numericality: { only_integer: true },
      inclusion: { in: 0..( ASSESSMENT_LABELS.size - 1 )}

  end

  ASSESSMENT_LABELS = I18n.t( 'activerecord.attributes.pcp_assessment.assessments' ).freeze

  class_methods do

    def assessment_label( i )
      ASSESSMENT_LABELS[ i ] unless i.nil?
    end

    def closed?( a )
      a == 2
    end
  
  end

  def assessment_label
    self.class.assessment_label( assessment )
  end

end