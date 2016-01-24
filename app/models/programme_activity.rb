require './lib/assets/app_helper.rb'
class ProgrammeActivity < ActiveRecord::Base
  include ApplicationModel

  has_many :dsr_prepare_records, foreign_key: :prep_activity_id, class_name: :DsrStatusRecord
  has_many :dsr_approve_records, foreign_key: :subm_activity_id, class_name: :DsrStatusRecord

  validate :start_and_finish_dates

  validates :start_date,
    date_field: { presence: false }

  validates :finish_date,
    date_field: { presence: false }

  # make sure that both dates are set

  def start_and_finish_dates
    if start_date.nil? then
      if finish_date.nil? then
        errors.add( :base, I18n.t( 'programme_activities.msg.no_dates' ))
      else
        self.start_date = self.finish_date
      end
    else # start_date is not nil
      if finish_date.nil? then
        self.finish_date = self.start_date
      else
        # both dates set - all good, but are they in sequence?
        errors.add( :base, I18n.t( 'programme_activities.msg.bad_dates' )) \
          unless self.start_date <= self.finish_date
      end
    end
  end

  def label_with_id
    text_and_id( :activity_label )
  end

  def project_id=( text )
    write_attribute( :project_id, AppHelper.clean_up( text, MAX_LENGTH_OF_PROGRAMME_IDS ))
  end

  def activity_id=( text )
    write_attribute( :activity_id, AppHelper.clean_up( text, MAX_LENGTH_OF_PROGRAMME_IDS ))
  end

end
