class Description
  include Mongoid::Document
  field :value, type: String
  embedded_in :descriptive, polymorphic: true
  
  def self.parse(data)
    # result, key = *case
    # when hash.is_a?(String) 
    #   [self.new, nil]
    # when hash.keys.first == "entry"
    #   [Entry.new, "entry"]
    # when hash.keys.first == "case"
    #   [Conditional.new, "case"]
    # when hash.keys.first == "upon"
    #   [Triggered.new, "upon"]
    # end
    result, key = 
      *case data
      when String
        [self, nil]
      when Hash
        [class_from_keyword[data.keys.first], data.keys.first]
      end
    result.new.tap {|d| d.parse(key ? data[key] : data)}
  end
  
  def self.class_from_keyword
    self.descendants.index_by(&:keyword)
  end
  
  def self.keyword
    nil
  end
    
  def parse(data)
    self.value = data.strip if data.is_a?(String)
  end
  
  def to_s(game_save)
    self.value
  end
end
