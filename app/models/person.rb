require './lib/assets/app_helper.rb'
class Person < ActiveRecord::Base
  include ApplicationModel
  
  has_many :accounts, dependent: :destroy
  has_many :contact_infos, dependent: :destroy
  has_many :responsibilities, dependent: :destroy
  accepts_nested_attributes_for :contact_infos, allow_destroy: true
  accepts_nested_attributes_for :accounts
  validates_associated :contact_infos
  validates_associated :accounts

  validates :formal_name,
    length: { maximum: MAX_LENGTH_OF_PERSON_NAMES },
    allow_blank: true

  validates :informal_name,
    length: { maximum: MAX_LENGTH_OF_PERSON_NAMES },
    allow_blank: true

  validate :check_names

  validates :email,
    length: { maximum: MAX_LENGTH_OF_EMAIL_STRING },
    format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/ },
    allow_blank: true,
    uniqueness: true

  # at least one of the two names must be given

  def check_names
    if formal_name.empty? and informal_name.empty?
      errors[:base] << I18n.t('people.msg.one_name_at_least')
    end
  end

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks

  def formal_name=( text )
    write_attribute( :formal_name, AppHelper.clean_up( text, MAX_LENGTH_OF_PERSON_NAMES, '' ))
  end

  def informal_name=( text )
    write_attribute( :informal_name, AppHelper.clean_up( text, MAX_LENGTH_OF_PERSON_NAMES, '' ))
  end

  # return (in)formal name unless it is empty, then return the other name

  def name
    self.formal_name.empty? ? self.informal_name : self.formal_name
  end

  def user_name
    self.informal_name.empty? ? self.formal_name : self.informal_name
  end

  def name_with_id
    text_and_id( :name )
  end

  # extend statistics

  def self.get_stats
    super << [ 'inactive', Person.where( involved: false ).count ]
  end

end
