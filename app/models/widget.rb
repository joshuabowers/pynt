class Widget < Construct
  field :name, type: String
  field :parameterized_name, type: String
  embeds_many :events, as: :triggerable
  recursively_embeds_many cascade_callbacks: true
  
  scope :portals, where(_type: "Portal")
  scope :scenery, where(_type: "Scenery")
  scope :items, where(_type: "Item")
  
  delegate :portals, :scenery, :items, to: :child_widgets
  
  before_save :parameterize_name

  def parse(data)
    super
    self.name = data["name"] if data["name"]
    data["events"].each {|event| self.events.build.parse(event)} if data["events"]
    parse_children(data)
  end
  
  def interactive?(game_state)
    (parent_widget.nil? || parent_widget.interactive?(game_state)) && super
  end
  
  def full_description(game_state)
    ([super] + child_widgets.map {|widget| widget.full_description(game_state)}).join(" ") if interactive?(game_state)
  end
  
  def full_hint(game_state)
    ([super] + child_widgets.map {|widget| widget.full_hint(game_state)}).join("\n") if interactive?(game_state)
  end
  
  def recursive_where(*options)
    child_widgets.where(*options).to_a + child_widgets.map {|widget| widget.recursive_where(*options)}.flatten
  end
    
  def recursive_events
    events + child_widgets.map(&:recursive_events).flatten
  end
private
  def parameterize_name
    self.parameterized_name = self.name.parameterize
  end

  def parse_children(data)
    self.child_widgets.destroy_all
    [Portal, Scenery, Item].each do |type|
      parse_children_of_type(data, type)
    end
  end
  
  def parse_children_of_type(data, type)
    key = type.name.tableize
    data[key].each do |object|
      self.child_widgets.build({}, type).parse(object)
    end if data[key]
  end
end
