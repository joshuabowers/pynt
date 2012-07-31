class Game
  include Mongoid::Document
  field :title, type: String
  field :parameterized_title, type: String
  field :description, type: String
  field :genre, type: String
  field :starting_room_id, type: Moped::BSON::ObjectId
  embeds_many :rooms
  belongs_to :author, class_name: "User", inverse_of: "authored_games"
  
  before_save :parameterize_title
  
  def starting_room
    self.starting_room_id.present? ? self.rooms.find(self.starting_room_id) : self.rooms.first
  end
  
  def starting_room=(room)
    self.starting_room_id = room.id
  end
  
  def load_last_save_for(user)
    user.game_saves.where(game_id: self.id).desc(:updated_at).first || new_save_game_for(user)
  end
  
  def execute(command_line, user)
    save = load_last_save_for(user)
    save.handle!(command_line)
  end
  
  def generate_map(options = {})
    options.reverse_merge! format: :svg, starting_room: starting_room_id
    options[:starting_room] = Moped::BSON::ObjectId.from_string(options[:starting_room]) unless options[:starting_room].is_a? Moped::BSON::ObjectId
    graph = {overlap: "scale", splines: true, sep: 0.5, bgcolor: "transparent"}
    node = {margin: "0.2, 0.055", style: "rounded", shape: "box"}
    edge = {arrowhead: "vee"}
    GraphViz.new("world-map", type: :digraph, use: :neato) do |g|
      graph.each {|key, value| g[key.to_s] = value}
      node.each {|key, value| g.node[key.to_s] = value}
      edge.each {|key, value| g.edge[key.to_s] = value}
      rooms.each do |room|
        node = g.add_nodes(room.parameterized_name, label: room.name)
        node["peripheries"] = 2 if room.id == options[:starting_room]
      end
      rooms.each do |room|
        from = g.get_node(room.parameterized_name)
        room.objects.portals.each do |portal|
          to = g.get_node(portal.destination_parameterized_name)
          g.add_edges(from, to)
        end
      end
    end.output(svg: String).html_safe
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
