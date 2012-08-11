class Construct
  include Mongoid::Document
  embeds_one :description, as: :descriptive
  embeds_one :hint, as: :hintable
  embeds_one :requirement, as: :contingent
  
  def parse(data)
    self.description = Description.parse(data["description"]) if data["description"]
    self.build_hint.parse(data["hint"]) if data["hint"]
    self.build_requirement.parse(data["requires"]) if data["requires"]
  end
  
  def interactive?(game_state)
    requirement.nil? || requirement.fulfilled?(game_state)
  end
  
  def full_description(game_state)
    description.try(:to_s, game_state)
  end
  
  def full_hint(game_state)
    hint.try(:description).try(:to_s, game_state)
  end
end
