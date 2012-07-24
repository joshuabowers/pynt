class Portal < GameObject
  field :destination_parameterized_name, type: String
  field :destination_id, type: String
  
  def destination
    self.container.game.rooms.find(self.destination_id)
  end
  
  def destination=(name)
    room = self.container.game.rooms.where(name: name).or(parameterized_name: name).first
    self.destination_id = room.id
  end
  
  def parse(hash)
    super
    self.destination_parameterized_name = hash["destination"].parameterize
  end
end
