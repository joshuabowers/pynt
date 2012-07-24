class Hint
  include Mongoid::Document
  embeds_one :description, as: :descriptive
  embedded_in :hintable, polymorphic: true
  
  def parse(hash)
    self.description = Description.parse(hash)
  end
end
