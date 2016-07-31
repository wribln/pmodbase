module ApplicationModel
  extend ActiveSupport::Concern

  # set variable to a default value

  def set_nil_default( var_name, var_value )
    if self.has_attribute?( var_name ) && ( read_attribute( var_name ).nil? )
      write_attribute( var_name, var_value )
    end
  end

  def set_blank_default( var_name, var_value )
    if self.has_attribute?( var_name ) && ( read_attribute( var_name ).blank? )
      write_attribute( var_name, var_value )
    end
  end

  # this is a helper which formats the record id in a standadized way:

  def some_text_and_id( some_text, some_id )
    t = some_text.to_s
    i = some_id.nil? ? '' : "[#{ some_id }]"
    t + (( t.empty? || i.empty? ) ? '' : ' ' ) + i
  end
  module_function :some_text_and_id
  
  def text_and_id( var )
    t = self.send( var ).to_s
    i = self.id.nil? ? '' : "[#{ self.id }]"
    t + (( t.empty? || i.empty? ) ? '' : ' ' ) + i
  end

  def assoc_text_and_id( assoc, var )
    a = self.send( assoc )
    a.present? ? a.text_and_id( var ) : ''
  end

  # this formats an internal .id

  def to_id
    "[#{ self.id }]" unless id.nil?
  end

  def some_id( id )
    id.blank? ? '' : "[#{ id }]"
  end

  # combine code and label for list boxes

  def code_and_label
    '' << try( :code ) << ' - ' << try( :label )
  end

  # this is the way to include class methods here:

  module ClassMethods

    # simple statistics, for more lines, add additional array items
    # containing two items each: the first being the label for the
    # count (second item); i.e. the initial array item MUST contain
    # the table name, normally followed by "Total" and the total count.
    #
    # Suggestion: 'Total' should remain capitalized, subitems should be
    # be lowercase to enable better recognition as subitem...

    def get_stats
      [[ self.model_name.human, 'Total', count ]]
    end

  end

end
