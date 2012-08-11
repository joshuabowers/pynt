class Description
  include Mongoid::Document
  embedded_in :descriptive, polymorphic: true
  
  def self.parse(data)
    key = 
      case data
      when String
        nil
      when Hash
        data.keys.first
      end
    class_from_keyword[key].new.tap {|d| d.parse(key ? data[key] : data)}
  end
  
  def self.class_from_keyword
    self.descendants.index_by(&:keyword)
  end
  
  def self.keyword
    nil
  end
    
  def parse(data)
  end
  
  def to_s(game_state)
  end
end
