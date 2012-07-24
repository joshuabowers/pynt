class Description
  include Mongoid::Document
  field :value, type: String
  embedded_in :descriptive, polymorphic: true
  
  def self.parse(hash)
    result, key = *case
    when hash.is_a?(String) 
      [self.new, nil]
    when hash.keys.first == "entry"
      [Entry.new, "entry"]
    when hash.keys.first == "case"
      [Conditional.new, "case"]
    end
    result.parse(key ? hash[key] : hash)
    result
  end
  
  def parse(hash)
    self.value = hash if hash.is_a?(String)
  end
  
  def to_s(game_save)
    self.value
  end
end
