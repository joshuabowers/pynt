class GameState
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :game_save
  field :command_line, type: String
  field :description, type: String
  field :hint, type: String
  field :added_item_ids, type: Array
  field :removed_item_ids, type: Array
  field :added_database_record_ids, type: Array
  field :updated_database_record_ids, type: Array
  field :updated_variables, type: Hash # NOTE: Moped::BSON::ObjectId => new_value
  field :moved_to_room_id, type: Moped::BSON::ObjectId
  embeds_one :event, as: :interactive
end
