class ReleaseNotesController < ApplicationController

  def index
    fpm=Util::FilePresentationManager.new
    @schema_diagram=fpm.schema_diagram
  end

end

