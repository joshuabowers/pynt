class Event
  include Mongoid::Document
  field :action, type: String
  embeds_one :description, as: :descriptive
  embedded_in :interactive, polymorphic: true
end
