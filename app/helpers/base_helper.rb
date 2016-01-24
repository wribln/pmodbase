module BaseHelper

  # formats the target for a link from the base page
  # to the respective controler

  def create_target( f )
    "/#{ f.underscore.pluralize }"
  end

end
