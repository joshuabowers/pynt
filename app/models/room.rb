require 'abbrev'

class Room < Widget
  field :parameterized_name, type: String
  field :valid_event_actions, type: Hash, default: {}
  field :yaml, type: String, default: -> { self.class.default_yaml }
  embedded_in :game
  
  before_save :parse_yaml, :parameterize_name, :abbreviate_event_actions
    
  def self.default_yaml
    {
      "room" => {
        "name" => "",
        "portals" => [{
          "name" => "",
          "destination" => "",
          "events" => [{
            "action" => "",
            "description" => ""
            }]
          }],
        "scenery" => [],
        "items" => [],
        "hint" => "",
        "description" => ""
      }
    }.stringify_keys.to_yaml
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
  
  def abbreviate_event_actions
    self.valid_event_actions = 
      Abbrev::abbrev((child_widgets | [self]).map {|o| o.events.map(&:action)}.flatten.uniq.map(&:downcase))
  end
end
