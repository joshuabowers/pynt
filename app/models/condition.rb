class Condition < Description
  field :comparisons, type: Hash, default: {}
  embedded_in :conditional
  
  def parse(hash)
    super(hash["description"] || hash["else"])
    self.comparisons = 
      case hash["when"]
      when String
        {hash["when"] => true}
      when Hash
        hash["when"]
      else
        {}
      end 
  end
  
  def self.keyword
    "when"
  end
  
  def satisfied?(game_save)
    game_save.all_comparisons_valid?(self.comparisons)
  end
end
