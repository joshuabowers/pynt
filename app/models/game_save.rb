class GameSave
  include Mongoid::Document
  include Mongoid::Timestamps
  field :game_id, type: Moped::BSON::ObjectId
  field :current_room_id, type: Moped::BSON::ObjectId
  embedded_in :user
  embeds_many :game_states do
    def current_room_history
      entry_state = where(moved_to_room_id: current_room.id).desc(:created_at).only(:created_at).first
      where(:created_at >= entry_state.created_at).asc(:created_at)
    end
  end
  
  def game
    @game ||= Game.find(self.game_id)
  end
  
  def current_room
    @current_room ||= self.game.rooms.find(self.current_room_id)
  end
  
  def current_room=(room)
    @current_room = room
    self.current_room_id = room.id
  end
  
  # NOTE: Updates self based off of what event does, returning a new GameState
  def handle!(event)
    nil
  end
end
