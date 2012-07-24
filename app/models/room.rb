class Room < GameObject
  field :parameterized_name, type: String
  embeds_many :objects, class_name: "GameObject", as: :container do
    def portals
      where(_type: "Portal")
    end
  end
  embedded_in :game
  
  before_save :parameterize_name

private
  def parameterize_name
    self.parameterized_name = self.name.parameterize
  end
end
