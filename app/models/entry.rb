class Entry < Description
  field :name, type: String
  field :parameterized_name, type: String
  field :read, type: Boolean, default: false
  embedded_in :definable, polymorphic: true
  
  before_save :parameterize_name
  
  def self.keyword
    "entry"
  end
  
  def parse(hash)
    super(hash["info"])
    self.name = hash["name"]
  end
private
  def parameterize_name
    self.parameterized_name = self.name.parameterize
  end
end
