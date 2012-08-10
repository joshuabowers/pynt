class Hint
  include Mongoid::Document
  embeds_one :description, as: :descriptive
  embedded_in :hintable, polymorphic: true
  
  def parse(data)
    self.description = Description.parse(data)
  end
end
