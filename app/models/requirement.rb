class Requirement
  include Mongoid::Document
  field :comparisons, type: Hash, default: {}
  embedded_in :contingent, polymorphic: true
  
  def parse(data)
    self.comparisons = 
      case data
      when String
        {data => true}
      when Hash
        data
      else
        {}
      end
  end
  
  def fulfilled?(game_save)
    game_save.all_comparisons_valid?(self.comparisons)
  end
end
