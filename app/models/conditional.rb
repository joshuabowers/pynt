class Conditional < Description
  embeds_many :branches
  
  def self.keyword
    "case"
  end
  
  def parse(data)
    data.each do |branch|
      self.branches.build.parse(branch)
    end
  end
  
  def to_s(game_save)
    self.branches.select {|branch| branch.fulfilled?(game_save)}.first.try(:to_s, game_save) || ""
  end
end
