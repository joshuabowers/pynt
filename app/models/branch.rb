class Branch < Description
  embeds_one :requirement, as: :contingent
  embedded_in :conditional
  
  def parse(data)
    super(data["description"] || data["else"])
    self.build_requirement.parse(data["when"])
  end
  
  def self.keyword
    "when"
  end
  
  def fulfilled?(game_save)
    requirement.nil? || requirement.fulfilled?(game_save)
  end
end
