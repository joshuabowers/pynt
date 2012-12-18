class Entry < Description
  field :name, type: String
  field :parameterized_name, type: String
  field :read, type: Boolean, default: false
  embeds_one :description, as: :descriptive
  embedded_in :definable, polymorphic: true
  
  before_save :parameterize_name
  
  def self.keyword
    "entry"
  end
  
  def parse(data)
    super
    self.name = data["name"]
    self.description = Description.parse(data["info"])
  end
  
  def to_s(game_state)
    description.try(:to_s, game_state)
  end
  
  def nested_description_of_type(game_state, type)
    super { self.description }
  end
private
  def parameterize_name
    self.parameterized_name = self.name.parameterize
  end
end
