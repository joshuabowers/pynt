class Branch < Description
  embeds_one :requirement, as: :contingent
  embeds_one :description, as: :descriptive
  embedded_in :conditional
  
  def parse(data)
    super
    self.build_requirement.parse(data["when"])
    self.description = Description.parse(data["description"] || data["else"])
  end
  
  def self.keyword
    "when"
  end
  
  def fulfilled?(game_state)
    requirement.nil? || requirement.fulfilled?(game_state)
  end
  
  def to_s(game_state)
    description.try(:to_s, game_state)
  end
end
