# The responsibility of this controller is the display of the requested help
# information. The only parameter of interest is :title. All help files are
# located under /views/help_pages

class HelpPagesController < ApplicationController
  initialize_feature FEATURE_ID_HELP_PAGES, FEATURE_ACCESS_ALL + FEATURE_ACCESS_NBP

  def show
    show_help_on params[ :title ]
  end

  def show_default
    show_help_on( :home )
  end

private

  def show_help_on( title )
    begin
      render title.downcase, layout: 'help_files'
    rescue ActionView::MissingTemplate
      render plain: t( 'help_pages.message.not_found', :topic => title ), :status => 404
    end
  end

end
