class GameSave
  include Mongoid::Document
  include Mongoid::Timestamps
  field :game_id, type: Moped::BSON::ObjectId
  field :current_room_id, type: Moped::BSON::ObjectId
  field :variables, type: Hash, default: {}
  embedded_in :user
  embeds_many :game_states, cascade_callbacks: true
  embeds_many :visited_rooms
  
  def game
    @game ||= Game.find(self.game_id)
  end
  
  def current_room
    self.game.rooms.find(self.current_room_id) if self.current_room_id
  end
    
  def current_room_history
    entry_state = game_states.where(moved_to_room_id: current_room_id).desc(:created_at).only(:created_at).first
    game_states.where(:created_at.gte => entry_state.created_at).asc(:created_at)
  end
  
  def enter_room!(room, portal = nil)
    update_visited_rooms(current_room, room, portal)
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
      self.enter_room!(destination, referent)
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
  
  def generate_map(options = {})
    options.reverse_merge! format: :svg
    file_name = map_file_name(options[:format])
    GraphViz.new("world-map", type: :digraph, use: :neato) do |g|
      g["overlap"] = "scale"
      g["splines"] = true
      g["sep"] = 0.5
      g["bgcolor"] = "transparent"
      g.node["margin"] = "0.2, 0.055"
      g.node["style"] = "rounded"
      g.node["shape"] = "box"
      g.edge["arrowhead"] = "vee"
      find_or_create_node = lambda {|room| g.get_node(room.parameterized_name) || g.add_nodes(room.parameterized_name, label: room.name) if room}
      self.visited_rooms.each do |visited_room|
        from = find_or_create_node.call(visited_room.from)
        to = find_or_create_node.call(visited_room.to)
        g.add_edges(from, to) if from && visited_room.via
      end
      if self.current_room
        current_room = g.get_node(self.current_room.parameterized_name)
        you_are_here = g.add_nodes("you_are_here", label: "You Are Here", shape: "plaintext")
        g.add_edges(you_are_here, current_room, id: "e_you_are_here")
      end
    end.output(file_name)
    File.read(file_name[options[:format]]).html_safe
  end
private
  def update_visited_rooms(from, to, via)
    unless visited_rooms.where(from_id: from.try(:id), to_id: to.try(:id), via_id: via.try(:id)).count > 0
      self.visited_rooms.build(from: from, to: to, via: via)
    end
  end

  def map_file_name(format)
    directory = "tmp/images/users/#{user.username}/maps/"
    FileUtils.mkdir_p(directory)
    { format => "#{directory}#{game.parameterized_title}-world-map.#{format}" }
  end
end
