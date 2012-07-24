class Entry < Description
  field :name, type: String
  
  def parse(hash)
    super(hash["info"])
    self.name = hash["name"]
  end
end
