class Widget
  include Mongoid::Document
  field :name, type: String
  field :parameterized_name, type: String
  embeds_one :description, as: :descriptive
  embeds_many :events, as: :interactive
  embeds_one :hint, as: :hintable
  embeds_one :requirement, as: :contingent
  recursively_embeds_many cascade_callbacks: true
  
  scope :portals, where(_type: "Portal")
  scope :scenery, where(_type: "Scenery")
  scope :items, where(_type: "Item")
  
  delegate :portals, :scenery, :items, to: :child_widgets
  
  before_save :parameterize_name

  def parse(hash)
    self.name = hash["name"] if hash["name"]
    self.description = Description.parse(hash["description"]) if hash["description"]
    self.build_requirement.parse(hash["requires"]) if hash["requires"]
    hash["events"].each {|event| self.events.build.parse(event)} if hash["events"]
    self.build_hint.parse(hash["hint"]) if hash["hint"]
    parse_children(hash)
  end

  def satisfied?(game_save)
    parent_satisfied = parent_widget ? parent_widget.satisfied?(game_save) : true
    parent_satisfied && (requirement ? requirement.satisfied?(game_save) : true)
  end
  
  def recursive_where(*options)
    child_widgets.where(*options).to_a + child_widgets.map {|widget| widget.recursive_where(*options)}.flatten
  end
  
  def full_description(game_save)
    if satisfied?(game_save)
      ([description.try(:to_s, game_save)] + child_widgets.map {|widget| widget.full_description(game_save)}).join(" ")
    end
  end
  
  def full_hint(game_save)
    if satisfied?(game_save)
      ([hint.try(:description).try(:to_s, game_save)] + child_widgets.map {|widget| widget.full_hint(game_save)}).join("\n")
    end
  end

  def recursive_events
    events + child_widgets.map(&:recursive_events).flatten
  end
private
  def parameterize_name
    self.parameterized_name = self.name.parameterize
  end

  def parse_children(hash)
    self.child_widgets.destroy_all
    [Portal, Scenery, Item].each do |type|
      parse_children_of_type(hash, type)
    end
  end
  
  def parse_children_of_type(hash, type)
    key = type.name.tableize
    hash[key].each do |object|
      self.child_widgets.build({}, type).parse(object)
    end if hash[key]
  end
end
