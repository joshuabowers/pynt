class Event
  include Mongoid::Document
  field :action, type: String
  field :updated_variables, type: Hash, default: {}
  field :toggled_variables, type: Array, default: []
  field :change_location, type: Boolean, default: false
  embeds_one :description, as: :descriptive
  embeds_one :hint, as: :hintable
  embedded_in :interactive, polymorphic: true
  
  def parse(hash)
    self.action = hash["action"]
    self.description = Description.parse(hash["description"]) if hash["description"]
    if hash["hint"]
      self.build_hint.parse(hash["hint"])
    end
    if hash["toggle"]
      case
      when hash["toggle"].is_a?(String)
        self.toggled_variables << hash["toggle"]
      when hash["toggle"].is_a?(Array)
        self.toggled_variables = hash["toggle"]
      end
    end
    if hash["update"]
      case
      when hash["update"].is_a?(String)
        self.change_location = true
      when hash["update"].is_a?(Hash)
        self.updated_variables = hash["update"]
      end
    end
  end
end
