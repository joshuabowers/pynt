module TerminalHelper
  def mark_up_description(game_state)
    game_state.description.gsub(/\[([^\]]+)\]/) do |s|
      object = game_state.game_save.current_room.objects.where(name: $1).first
      content_tag(:span, $1, class: object.class.name.underscore)
    end.html_safe
  end
end
