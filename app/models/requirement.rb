class Requirement
  include Mongoid::Document
  field :comparisons, type: Hash, default: {}
  embedded_in :contingent, polymorphic: true
  
  def parse(hash)
    self.comparisons = 
      case hash
      when String
        {hash => true}
      when Hash
        hash
      else
        {}
      end
  end
  
  def satisfied?(game_save)
    game_save.all_comparisons_valid?(self.comparisons)
  end
end
