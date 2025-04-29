module UsersHelper
  def sortable(column, title = nil)
    title ||= column.titleize
    direction = column == params[:sort] && params[:direction] == "asc" ? "desc" : "asc"
    css_class = column == params[:sort] ? "sortable #{params[:direction]}" : "sortable"
    link_to title, users_path(sort: column, direction: direction), class: css_class
  end
end