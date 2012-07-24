class GameObject
  include Mongoid::Document
  field :name, type: String
  # field :parameterized_name, type: String
  embeds_one :description, as: :descriptive
  embeds_many :events, as: :interactive
  embeds_one :hint, as: :hintable
  embedded_in :container, polymorphic: true
  
  def parse(hash)
    self.name = hash["name"] if hash["name"]
    self.description = Description.parse(hash["description"]) if hash["description"]
    if hash["events"]
      hash["events"].each do |event|
        self.events.build.parse(event)
      end
    end
    if hash["hint"]
      self.build_hint.parse(hash["hint"])
    end
  end
  
  # before_save :parameterize_name
# private
#   def parameterize_name
#     self.parameterized_name = self.name.parameterize
#   end
end
