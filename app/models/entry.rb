class Entry < Description
  field :name, type: String
  embedded_in :definable, polymorphic: true
  
  def parse(hash)
    super(hash["info"])
    self.name = hash["name"]
  end
end
