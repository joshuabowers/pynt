class Room < GameObject
  field :parameterized_name, type: String
  field :yaml, type: String
  embeds_many :objects, class_name: "GameObject", as: :container do
    def portals
      where(_type: "Portal")
    end
    def items
      where(_type: "Item")
    end
  end
  embedded_in :game
  
  before_save :parameterize_name, :parse_yaml
  
  def parse(hash)
    super
    hash["portals"].each do |portal|
      self.objects.build({}, Portal).parse(portal)
    end
    hash["scenery"].each do |object|
      self.objects.build.parse(object)
    end
    hash["items"].each do |item|
      self.objects.build({}, Item).parse(item)
    end
  end

private
  def parameterize_name
    self.parameterized_name = self.name.parameterize
  end
  
  def parse_yaml
    if self.yaml
      r = YAML.load(self.yaml)
      self.parse(r["room"])
    end
  end
end
