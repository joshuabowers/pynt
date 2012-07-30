class GameObject
  include Mongoid::Document
  field :name, type: String
  embeds_one :description, as: :descriptive
  embeds_many :events, as: :interactive
  embeds_one :hint, as: :hintable
  embeds_one :requirement, as: :contingent
  embedded_in :container, polymorphic: true
  
  def parse(hash)
    self.name = hash["name"] if hash["name"]
    self.description = Description.parse(hash["description"]) if hash["description"]
    self.build_requirement.parse(hash["requires"]) if hash["requires"]
    hash["events"].each {|event| self.events.build.parse(event)} if hash["events"]
    self.build_hint.parse(hash["hint"]) if hash["hint"]
  end
  
  def satisfied?(game_save)
    requirement ? requirement.satisfied?(game_save) : true
  end
end
