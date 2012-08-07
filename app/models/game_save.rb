class GameSave
  include Mongoid::Document
  include Mongoid::Timestamps
  field :game_id, type: Moped::BSON::ObjectId
  field :current_room_id, type: Moped::BSON::ObjectId
  field :variables, type: Hash, default: {}
  embedded_in :user
  embeds_many :game_states, cascade_callbacks: true
  embeds_many :visited_rooms
  
  after_build :setup_initial_save_state
  
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
  
  def handle!(command_line)
    game_states.build.tap {|game_state| game_state.handle(command_line)}.tap { save }
  end
  
  def update_visited_rooms(from, to)
    unless visited_rooms.where(from_id: from.try(:id), to_id: to.try(:id)).count > 0
      self.visited_rooms.build(from: from, to: to)
    end
  end
  
  def generate_map(options = {})
    options.reverse_merge! format: :svg
    graph = {overlap: "scale", splines: true, sep: 0.5, bgcolor: "transparent"}
    node = {margin: "0.2, 0.055", style: "rounded", shape: "box"}
    edge = {arrowhead: "vee"}
    GraphViz.new("world-map", type: :digraph, use: :neato) do |g|
      graph.each {|key, value| g[key.to_s] = value}
      node.each {|key, value| g.node[key.to_s] = value}
      edge.each {|key, value| g.edge[key.to_s] = value}
      find_or_create_node = lambda {|room| g.get_node(room.parameterized_name) || g.add_nodes(room.parameterized_name, label: room.name) if room}
      self.visited_rooms.each do |visited_room|
        from = find_or_create_node.call(visited_room.from)
        to = find_or_create_node.call(visited_room.to)
        g.add_edges(from, to) if from
      end
      if self.current_room
        current_room = g.get_node(self.current_room.parameterized_name)
        you_are_here = g.add_nodes("you_are_here", label: "You Are Here", shape: "plaintext")
        g.add_edges(you_are_here, current_room, id: "e_you_are_here")
      end
    end.output(svg: String).html_safe
  end
private
  def setup_initial_save_state
    game_states.build.start_game(game.starting_room)
  end
end
