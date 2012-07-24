class Event
  include Mongoid::Document
  field :action, type: String
  embeds_one :description, as: :descriptive
  embedded_in :interactive, polymorphic: true
  
  def parse(hash)
    self.action = hash["action"]
    self.description = Description.parse(hash["description"]) if hash["description"]
  end
end
