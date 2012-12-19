class Event < Construct
  field :action, type: String
  field :updated_variables, type: Hash, default: {}
  field :toggled_variables, type: Array, default: []
  field :change_location, type: Boolean, default: false
  field :add_to_inventory, type: Boolean, default: false
  field :remove_from_inventory, type: Boolean, default: false
  embedded_in :triggerable, polymorphic: true
  
  def parse(data)
    super
    self.action = data["action"]
    self.toggled_variables = Array.wrap(data["toggle"])
    case data["update"]
    when /^location$/
      self.change_location = true
    when /^(add-to|remove-from)-inventory$/
      self.send("#{data['update']}=".underscore, true)
    when Hash
      self.updated_variables = data["update"]
    end
  end
  
  def full_description(game_state)
    ([super] + widgets_with_triggered_descriptions(game_state).map {|w| w.full_description(game_state)}).join(" ")
  end
  
  def full_hint(game_state)
    ([super] + widgets_with_triggered_hints(game_state).map {|w| w.full_hint(game_state)}).join(" ")
  end
private
  def widgets_with_triggered_descriptions(game_state)
    game_state.referent.recursive_where("description.effects.action" => game_state.event.action, game_state: game_state)
  end
  
  def widgets_with_triggered_hints(game_state)
    game_state.referent.recursive_where("hint.description.effects.action" => game_state.event.action, game_state: game_state)
  end
end
