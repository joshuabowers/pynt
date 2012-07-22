module ApplicationHelper
  def link_to_section(title, url, options = {})
    options.reverse_merge! class: "current"
    link_to_unless_current title, url do
      link_to(title, url, class: options[:class])
    end
  end
end
