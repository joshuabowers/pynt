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
  
  def to_s(game_state)
    fulfilled_branch(game_state).try(:to_s, game_state) || ""
  end
  
  def nested_description_of_type(game_state, type)
    super { fulfilled_branch(game_state) }
  end
private
  def fulfilled_branch(game_state)
    self.branches.select {|branch| branch.fulfilled?(game_state)}.first
  end
end
