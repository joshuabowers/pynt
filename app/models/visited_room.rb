class VisitedRoom
  include Mongoid::Document
  field :from_id, type: Moped::BSON::ObjectId
  field :to_id, type: Moped::BSON::ObjectId
  embedded_in :game_save
  
  def from
    game_save.game.rooms.find(from_id) if from_id
  end
  
  def to
    game_save.game.rooms.find(to_id) if to_id
  end
  
  def via
    from.objects.portals.where(destination_parameterized_name: to.parameterized_name).first if from_id && to_id
  end
  
  def from=(room)
    self.from_id = room.id if room
  end
  
  def to=(room)
    self.to_id = room.id if room
  end
end
