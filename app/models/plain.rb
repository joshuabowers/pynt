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
end
