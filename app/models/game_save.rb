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
    self.game.rooms.find(self.current_room_id)
  end
    
  def current_room_history
    entry_state = game_states.where(moved_to_room_id: current_room_id).desc(:created_at).only(:created_at).first
    game_states.where(:created_at.gte => entry_state.created_at).asc(:created_at)
  end
  
  def enter_room!(room)
    self.current_room_id = room.id
    self.variables["#{room.parameterized_name}-times-entered"] ||= 0
    self.variables["#{room.parameterized_name}-times-entered"] += 1
    self.save!
    self.game_states.create({
      description: room.description.to_s(self),
      hint: room.hint.try(:description).try(:to_s, self),
      moved_to_room_id: room.id
    })
  end
  
  def all_comparisons_valid?(comparisons)
    comparisons.all? do |key, value| 
      case key
      when "first-enter"
        variable = self.variables["#{current_room.parameterized_name}-times-entered"]
        value ? variable == 1 : variable > 1
      else
        (self.variables[key] || false) == value
      end
    end
  end
  
  # NOTE: Updates self based off of what event does, returning a new GameState
  def handle!(command)
    referent = self.current_room.objects.where(name: command.referent).first
    event = referent.events.where(action: command.action).first
    updated_variables = {}
    event.toggled_variables.each do |variable|
      self.variables[variable] = !self.variables[variable]
    end
    event.updated_variables.each do |key, value|
      self.variables[key] = value
    end
    self.save!
    if event.change_location
      destination = self.game.rooms.where(parameterized_name: referent.destination_parameterized_name).first
      self.enter_room!(destination)
    else
      self.game_states.create({
        command_line: command.to_s,
        description: event.description.try(:to_s, self),
        hint: event.hint.try(:description).try(:to_s, self),
        updated_variables: Hash[*event.updated_variables.keys.map {|key| [key, self.variables[key]]}.flatten] 
      })
    end
  rescue Exception => e
    self.game_states.build({
      id: Moped::BSON::ObjectId.new,
      command_line: command.to_s,
      # description: e.to_s + "\n" + e.backtrace.join("\n")
      description: "Try as hard as you might, you simply cannot do that."
    })
  end
  
  # NOTE: Need to come up with a way of keeping track of:
  # * which rooms the user has been in,
  # * which doors the user has inspected / used
  # * which doors are currently locked
  def generate_map(options = {})
    options.reverse_merge! format: :svg
    file_name = map_file_name(options[:format])
    GraphViz.new("world-map", type: :digraph, use: :neato) do |g|
      g["overlap"] = false
      g["splines"] = true
      g["bgcolor"] = "transparent"
      g.node["margin"] = "0.1"
      g.node["style"] = "rounded"
      current_room = g.add_nodes(self.current_room.parameterized_name, label: self.current_room.name, shape: "box")
      you_are_here = g.add_nodes("you_are_here", label: "You Are Here", shape: "plaintext")
      here_there_be = g.add_nodes("here_there_be", label: "Here There be Dragons")
      g.add_edges(you_are_here, current_room)
    end.output(file_name)
    File.read(file_name[options[:format]]).html_safe
  end
private
  def map_file_name(format)
    directory = "tmp/images/users/#{user.username}/maps/"
    FileUtils.mkdir_p(directory)
    { format => "#{directory}#{game.parameterized_title}-world-map.#{format}" }
  end
end
