class GameSave
  include Mongoid::Document
  include Mongoid::Timestamps
  field :game_id, type: Moped::BSON::ObjectId
  field :current_room_id, type: Moped::BSON::ObjectId
  field :variables, type: Hash, default: {}
  embedded_in :user
  embeds_many :game_states, cascade_callbacks: true
  
  def game
    @game ||= Game.find(self.game_id)
  end
  
  def current_room
    @current_room ||= self.game.rooms.find(self.current_room_id)
  end
    
  def current_room_history
    entry_state = game_states.where(moved_to_room_id: current_room_id).desc(:created_at).only(:created_at).first
    game_states.where(:created_at.gte => entry_state.created_at).asc(:created_at)
  end
  
  def enter_room!(room)
    self.current_room_id = room.id
    self.variables["#{room.parameterized_name}-times-entered"] ||= 0
    self.variables["#{room.parameterized_name}-times-entered"] += 1
    self.game_states.build({
      description: room.description.to_s(self),
      moved_to_room_id: room.id
    })
    self.save!
  end
  
  def all_comparisons_valid?(comparisons)
    comparisons.all? do |key, value| 
      case key
      when "first-enter"
        variable = self.variables["#{current_room.parameterized_name}-times-entered"]
        value ? variable == 1 : variable > 1
      else
        self.variables[key] == value
      end
    end
  end
  
  # NOTE: Updates self based off of what event does, returning a new GameState
  def handle!(command)
    referent = self.current_room.objects.where(name: command.referent).first
    event = referent.events.where(action: command.action).first
    self.game_states.create({
      command_line: command.to_s,
      description: event.description.to_s(self)
    })
  rescue Exception => e
    self.game_states.build({
      id: Moped::BSON::ObjectId.new,
      command_line: command.to_s,
      description: "Try as hard as you might, you simply cannot do that."
    })
  end
end
