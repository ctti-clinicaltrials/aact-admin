module ApplicationHelper
  def markdown(body_text)
    options = {hard_wrap: true,
               filter_html: true,
               autolink: true,
               no_intra_emphasis: true,
               fenced_code_blocks: true,
               gh_blockcode: true
              }

    markdown_to_html = Redcarpet::Markdown.new(Redcarpet::Render::HTML, options)
    markdown_to_html.render(body_text).html_safe
  end
end
