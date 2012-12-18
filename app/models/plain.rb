class Plain < Description
  field :value, type: String
  
  def self.keyword
    nil
  end
  
  def parse(data)
    self.value = data.strip if data.is_a?(String)
  end
  
  def to_s(game_state)
    self.value
  end
  
  def nested_description_of_type(game_state, type)
    super
  end
end
