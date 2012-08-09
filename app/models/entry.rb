class Entry < Description
  field :name, type: String
  field :read, type: Boolean, default: false
  embedded_in :definable, polymorphic: true
  
  def parse(hash)
    super(hash["info"])
    self.name = hash["name"]
  end
end
