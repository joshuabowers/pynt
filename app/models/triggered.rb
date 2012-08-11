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
    # Two times this will come up: triggered eventss, and room inspection.
    action = game_state.moved_to_room? ? nil : game_state.command.action
    effects.select {|effect| effect.action == action}.first.try(:to_s, game_state) || ""
  end
end
