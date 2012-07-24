class Event
  include Mongoid::Document
  field :action, type: String
  embeds_one :description, as: :descriptive
  embeds_one :hint, as: :hintable
  embedded_in :interactive, polymorphic: true
  
  def parse(hash)
    self.action = hash["action"]
    self.description = Description.parse(hash["description"]) if hash["description"]
    if hash["hint"]
      self.build_hint.parse(hash["hint"])
    end
  end
end
