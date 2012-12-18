class Triggered < Description
  embeds_many :effects
  
  def self.keyword
    "upon"
  end
  
  def parse(data)
    super
    data.each do |effect|
      self.effects.build.parse(effect)
    end
  end
  
  def to_s(game_state)
    active_effect(game_state).try(:to_s, game_state) || ""
  end
  
  def nested_description_of_type(game_state, type)
    super { active_effect(game_state) }
  end
private
  def active_effect(game_state)
    # Two times this will come up: triggered eventss, and room inspection.
    action = game_state.moved_to_room? ? nil : game_state.command.action
    effects.select {|effect| effect.action == action}.first
  end
end
