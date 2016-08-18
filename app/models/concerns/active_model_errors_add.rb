# this replaces the RoR errors.add method by a more sophisticated
# method for situations where standard validation messages are
# generated for associations.
#
# (a) the attribute for association validations is the name of the association;
#     in order to avoid adding additional association labels for the I18n, this
#     method replaces the association name with the corresponding foreign key 
# (b) it provides a parameter :assoc for the :blank_assoc error message containing
#     the human name of the model.

module ActiveModelErrorsAdd

  def add( attribute, message = :invalid, options = {})
    if attribute != :base
      all_assocs = @base.class.reflect_on_all_associations( :belongs_to )
      this_assoc = nil
      all_assocs.each do |a|
        if a.name == attribute
          this_assoc = a
          break
        end
      end
    end
    if this_assoc.nil?
      super
    elsif message == :blank
      super( this_assoc.foreign_key, :blank_assoc, options.merge( assoc: this_assoc.klass.model_name.human ))
    else
      super( this_assoc.foreign_key, message, options )
    end
  end
end

class ActiveModel::Errors
  prepend ActiveModelErrorsAdd
end
