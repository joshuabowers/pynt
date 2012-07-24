class Condition < Description
  field :comparisons, type: Hash, default: {}
  embedded_in :conditional
  
  def parse(hash)
    super(hash["description"] || hash["else"])
    case 
    when hash["when"].is_a?(String)
      self.comparisons[hash["when"]] = true
    when hash["when"].is_a?(Hash)
      self.comparisons = hash["when"]
    end
  end
  
  def satisfied?(game_save)
    # Logic to determine whether something is satisfied...
  end
end
