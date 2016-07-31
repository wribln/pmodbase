# include this when you need the given_file_type_exists? functionality
# 
# include CfrFileTypeCheck
#
# + add error message in I18n files for <table_name>.msg.bad_ft_id

module CfrFileTypeCheck
  extend ActiveSupport::Concern

  # check if related record exists

  def given_file_type_exists( cfr_file_type_id = :cfr_file_type_id )
    ft_id = self.send( cfr_file_type_id )
    if ft_id.present? then
      errors.add( :cfr_file_type_id, I18n.t( "#{ self.class.table_name }.msg.bad_ft_id" )) \
        unless CfrFileType.exists?( ft_id )
    end
  end

end