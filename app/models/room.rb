class Room < GameObject
  field :parameterized_name, type: String
  field :yaml, type: String, default: -> { self.class.default_yaml }
  embeds_many :objects, class_name: "GameObject", as: :container do
    def portals
      where(_type: "Portal")
    end
    def items
      where(_type: "Item")
    end
  end
  embedded_in :game
  
  before_save :parse_yaml, :parameterize_name
  
  def self.default_yaml
    {
      "room" => {
        "name" => "",
        "portals" => [
          {
            "name" => "",
            "destination" => "",
            "events" => [
              {
                "action" => "",
                "description" => ""
              }
              ]
          }
          ],
        "scenery" => [
          ],
        "items" => [
          ],
        "hint" => "",
        "description" => ""
      }
    }.stringify_keys.to_yaml
  end
  
  def parse(hash)
    self.objects.destroy_all
    super
    hash["portals"].each do |portal|
      self.objects.build({}, Portal).parse(portal)
    end if hash["portals"]
    hash["scenery"].each do |object|
      self.objects.build.parse(object)
    end if hash["scenery"]
    hash["items"].each do |item|
      self.objects.build({}, Item).parse(item)
    end if hash["items"]
  end

private
  def parameterize_name
    self.parameterized_name = self.name.parameterize
  end
  
  def parse_yaml
    if self.yaml
      self.yaml = self.yaml.gsub(/\t/, '  ')
      r = YAML.load(self.yaml)
      self.parse(r["room"])
    end
  end
end
