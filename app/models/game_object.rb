class GameObject
  include Mongoid::Document
  field :name, type: String
  embeds_one :description, as: :descriptive
  embeds_many :events, as: :interactive
  embedded_in :container, polymorphic: true
end
