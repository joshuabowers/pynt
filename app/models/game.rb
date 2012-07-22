class Game
  include Mongoid::Document
  field :title, type: String
  field :description, type: String
  field :genre, type: String
end
