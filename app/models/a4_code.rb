require './lib/assets/app_helper.rb' 
class A4Code < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include ACodeModel

  # Sub-Discipline/-System

  validates :code,
    format: { with: /\A.[A-Z0-9&]+\-[A-Z0-9&]+\z/, message: I18n.t( 'a_code_modules.msg.bad_code_syntax2')},
    length: { maximum: 7 }

  validate :a3_code_part_exists

  scope :as_code, -> ( c ){ where( 'code LIKE ?', "___-#{ c }%" )}

  # provide a way to access parts of code

  def a3_code_part
    code.split( '-', 2).first unless code.nil?
  end

  def a4_code_part
    code.split( '-', 2).last unless code.nil?
  end

  def self.join_codes( a3, a4 )
    a3 + '-' + a4
  end

  # make sure first part is a valid a3 code

  def a3_code_part_exists
    errors.add( :code, I18n.t( 'a4_codes.msg.bad_a3_part' )) \
      unless A3Code.exists?( code: a3_code_part )
  end

end
