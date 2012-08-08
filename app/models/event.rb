class Event
  include Mongoid::Document
  field :action, type: String
  field :updated_variables, type: Hash, default: {}
  field :toggled_variables, type: Array, default: []
  field :change_location, type: Boolean, default: false
  embeds_one :description, as: :descriptive
  embeds_one :hint, as: :hintable
  embeds_one :requirement, as: :contingent
  embedded_in :interactive, polymorphic: true
  
  def parse(hash)
    self.action = hash["action"]
    self.description = Description.parse(hash["description"]) if hash["description"]
    self.build_hint.parse(hash["hint"]) if hash["hint"]
    self.build_requirement.parse(hash["requires"]) if hash["requires"]
    self.toggled_variables = Array.wrap(hash["toggle"])
    case hash["update"]
    when /^location$/
      self.change_location = true
    when Hash
      self.updated_variables = hash["update"]
    end
  end
  
  def satisfied?(game_save)
    requirement ? requirement.satisfied?(game_save) : true
  end
  
  def full_description(game_save)
    description.try(:to_s, game_save)
  end
  
  def full_hint(game_save)
    hint.try(:description).try(:to_s, game_save)
  end
end
