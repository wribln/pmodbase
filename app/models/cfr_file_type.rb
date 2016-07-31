require './lib/assets/app_helper.rb'
class CfrFileType < ActiveRecord::Base
  include ApplicationModel

  has_many :cfr_records, inverse_of: :cfr_file_types

  validates :extensions,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_NOTE },
    format: { with: /\A(\w+)(,\w+)*\z/, message: I18n.t( 'cfr_file_types.msg.bad_format' )}

  validates :label,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validate :uniqueness_of_extension

  scope :find_by_extension, ->( ext ){ where "extensions LIKE \"%#{ ext }%\"" }

  # ensure that an extension is not assigned twice; this appears expensive
  # but since file type records are not modified often, I thought it's worth it

  def uniqueness_of_extension
    return if extensions.blank?
    ft0 = extensions.split( ',' )
    ftr = CfrFileType.find_each do |ft|
      next if ft.id == self.id
      ftd = ft.extensions.split( ',' ) & ft0
      unless ftd.empty?
        errors.add( :extensions, I18n.t( 'cfr_file_types.msg.dup_ext', dup: ftd, id: ft.id ))
        break
      end
    end
  end

  # retrieve label for given extension or return default label

  def self.file_type_label( ext )
    ( ft = self.get_file_type( ext )) ? ft.label : self.human_attribute_name( :unknown_type )
  end

  # determine file type from extension

  def self.get_file_type( ext )
    unless ext.blank? || ( ft = CfrFileType.find_by_extension( ext )).empty?
      ft[ 0 ]
    end
  end

  # remove all white space from string

  def extensions=( text )
    write_attribute( :extensions, text.gsub( /\s+/,'' ))
  end

  # remove leading and trailing blanks

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text ))
  end  

end
