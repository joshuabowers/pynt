class Description
  include Mongoid::Document
  field :value, type: String
  embedded_in :descriptive, polymorphic: true
end
