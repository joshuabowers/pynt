module ApplicationHelper
  def link_to_section(title, url, options = {})
    options.reverse_merge! class: "current"
    link_to_unless_current title, url do
      link_to(title, url, class: options[:class])
    end
  end
  
  def metadata(data)
    content_for :page_metadata do
      data.map do |key, value|
        tag :meta, name: key, content: value
      end.join('\n').html_safe
    end
  end
  
  def meta_tag(name, content)
    metadata(name => content)
  end
end
