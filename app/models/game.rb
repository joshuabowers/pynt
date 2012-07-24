class Game
  include Mongoid::Document
  field :title, type: String
  field :parameterized_title, type: String
  field :description, type: String
  field :genre, type: String
  field :starting_room_id, type: Moped::BSON::ObjectId
  embeds_many :rooms
  
  before_save :parameterize_title
  
  def starting_room
    self.rooms.find(self.starting_room_id)
  end
  
  def starting_room=(room)
    self.starting_room_id = room.id
  end
  
  # Should return a GameSave object, essentially the one that user has.
  # NOTE: Will create a new GameSave, should the user not already have one.
  def load_last_save_for(user)
    user.game_saves.where(game_id: self.id).desc(:updated_at).first || new_save_game_for(user)
  end
  
  # Parses command_line into an Event object. Uses this to alter user's GameSave
  # Should return a GameState object, representing the change in state that command_line causes.
  # Also, updates user's GameSave object.
  def execute(command_line, user)
    save = load_last_save_for(user)
    command = Command.parse(command_line)
    save.handle!(command)
  end
private
  def parameterize_title
    self.parameterized_title = self.title.parameterize
  end
  
  # May need to do some extra processing of the new save files, here.
  def new_save_game_for(user)
    game_save = user.game_saves.create(game_id: self.id)
    game_save.enter_room!(self.starting_room)
    game_save.user.save!
    game_save
  end
end
