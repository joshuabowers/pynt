class Effect < Description
  field :action, type: String
  embeds_one :description, as: :descriptive
  embedded_in :triggered
  
  # validates :action, presence: true
  validates :description, presence: true
  
  def self.keyword
    "action"
  end
  
  def parse(data)
    super
    self.action = data["action"]
    self.description = Description.parse(data["description"] || data["else"])
  end
  
  def to_s(game_state)
    description.try(:to_s, game_state)
  end
end
