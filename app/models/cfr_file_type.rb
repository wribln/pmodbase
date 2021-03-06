require './lib/assets/app_helper.rb'
class CfrFileType < ActiveRecord::Base
  include ApplicationModel

  has_many :cfr_records, inverse_of: :cfr_file_types

  # externally, show a list of lower-case extensions "ext1[,ext2,ext3,...]"
  # internally, hold the list with leading and trailing comma to aid correct searching

  attr_accessor :extensions

  validates :extensions_internal,
    allow_blank: true,
    length: { maximum: MAX_LENGTH_OF_NOTE },
    format: { with: /\A(,\w+)+,\z/, message: I18n.t( 'cfr_file_types.msg.bad_format' )}

  validates :label,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validate :uniqueness_of_extension

  scope :find_by_extension, ->( ext ){ where "extensions_internal LIKE \"%,#{ ext },%\"" }
  default_scope  { order( label: :asc )}

  set_trimmed :label

  # ensure that an extension is not assigned twice; this appears expensive
  # but since file type records are not modified often, I thought it's worth it

  def uniqueness_of_extension
    return if extensions.blank?
    ft0 = extensions.split( ',' )
    ftr = CfrFileType.where.not( id: self.id, extensions_internal: nil ).unscope( :order ).each do |ft|
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

  # remove all white space from string, make it lowercase, and add leading and trailing comma

  def extensions=( text )
    text.blank? ? nil : write_attribute( :extensions_internal, ',' + text.gsub( /\s+/,'' ).downcase + ',' )
  end

  # somehow a getter method for views

  def extensions
    read_attribute( :extensions_internal ).try( :slice, 1..-2 )
  end

end
