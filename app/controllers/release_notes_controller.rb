class ReleaseNotesController < ApplicationController

  def index
    fpm=Util::FilePresentationManager.new
    @schema_diagram=fpm.schema_diagram
    @nested_criteria_example=fpm.nested_criteria_example
    @releases = Release.all.order(created_at: :desc)
  end

end
