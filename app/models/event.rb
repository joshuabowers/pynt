class Event < Construct
  field :action, type: String
  field :updated_variables, type: Hash, default: {}
  field :toggled_variables, type: Array, default: []
  field :change_location, type: Boolean, default: false
  embedded_in :triggerable, polymorphic: true
  
  def parse(data)
    super
    self.action = data["action"]
    self.toggled_variables = Array.wrap(data["toggle"])
    case data["update"]
    when /^location$/
      self.change_location = true
    when Hash
      self.updated_variables = data["update"]
    end
  end
end
