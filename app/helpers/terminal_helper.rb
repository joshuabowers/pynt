module TerminalHelper
  def mark_up_description(game_state)
    game_state.description.gsub(/<([^<]+)</) do |s|
      content_tag(:span, $1, class: "mirrored")
    end.gsub(/\[([^\]]+)\]/) do |s|
      object = game_state.current_room.recursive_where(name: $1).first
      content_tag(:span, $1, class: object.class.name.underscore)
    end.html_safe
  end
end
