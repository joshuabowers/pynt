class Conditional < Description
  embeds_many :conditions
  
  def self.keyword
    "case"
  end
  
  def parse(hash)
    hash.each do |condition|
      self.conditions.build.parse(condition)
    end
  end
  
  def to_s(game_save)
    condition = self.conditions.select {|condition| condition.satisfied?(game_save)}.first
    condition ? condition.to_s(game_save) : ""
  end
end
