class Widget
  include Mongoid::Document
  field :name, type: String
  embeds_one :description, as: :descriptive
  embeds_many :events, as: :interactive
  embeds_one :hint, as: :hintable
  embeds_one :requirement, as: :contingent
  recursively_embeds_many
  
  scope :portals, where(_type: "Portal")
  scope :scenery, where(_type: "Scenery")
  scope :items, where(_type: "Item")
  
  delegate :portals, :scenery, :items, to: :child_widgets

  def parse(hash)
    self.name = hash["name"] if hash["name"]
    self.description = Description.parse(hash["description"]) if hash["description"]
    self.build_requirement.parse(hash["requires"]) if hash["requires"]
    hash["events"].each {|event| self.events.build.parse(event)} if hash["events"]
    self.build_hint.parse(hash["hint"]) if hash["hint"]
    parse_children(hash)
  end

  def satisfied?(game_save)
    requirement ? requirement.satisfied?(game_save) : true
  end
private
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
