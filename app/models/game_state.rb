class GameState
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :game_save
  field :description, type: String
  field :hint, type: String
  field :added_item_id, type: Moped::BSON::ObjectId
  field :updated_variables, type: Hash
  field :moved_to_room_id, type: Moped::BSON::ObjectId
  embeds_one :command
  embeds_one :entry, as: :definable
  embeds_one :removed_item, as: :inventory, class_name: "Item"
  
  delegate :items, :variables, :current_room, :game, to: :game_save
  delegate :referent, :event, to: :command
    
  def moved_to_room?
    self.moved_to_room_id.present?
  end
  
  def added_item
    items.find(self.added_item_id) if self.added_item_id
  end
  
  def handle(command_line)
    self.build_command.parse(command_line)
    if valid?
      modify_variables
      clone_entry
      update_inventory
      enter_room(referent.destination) if event.change_location
      cache_modified_variables
    end
    output
  end
  
  def start_game(starting_room)
    enter_room(starting_room)
    cache_modified_variables
    output
  end
  
  def source
    @source ||= moved_to_room? ? current_room : event
  end
private
  def enter_room(destination)
    game_save.update_visited_rooms(current_room, destination)
    game_save.current_room_id = destination.id
    self.variables["#{destination.parameterized_name}-times-entered"] ||= 0
    self.variables["#{destination.parameterized_name}-times-entered"] += 1
    self.moved_to_room_id = destination.id
  end
  
  def modify_variables
    event.toggled_variables.each do |variable|
      self.variables[variable] = !self.variables[variable]
    end
    event.updated_variables.each do |key, value|
      self.variables[key] = value
    end
  end
  
  def clone_entry
    if event.description.is_a? Entry
      self.entry = event.description.clone
      previous_entry = game_save.entries.where(name: self.entry.name).first
      if previous_entry
        previous_entry.description = self.entry.description
      else
        game_save.entries << self.entry.clone
      end
    end
  end
  
  def update_inventory
    case
    when event.add_to_inventory
      items << referent.clone.tap do |item|
        self.added_item_id = item.id
        variables["item-#{item.parameterized_name}"] = true
      end
    when event.remove_from_inventory
      self.removed_item = items.where(parameterized_name: referent.parameterized_name).first.clone
      variables["item-#{removed_item.parameterized_name}"] = false
    end
  end
  
  def cache_modified_variables
    if game_save.variables_changed?
      old_variables, new_variables = *game_save.variables_change.map(&:to_a)
      self.updated_variables = Hash[*(new_variables - old_variables).flatten]
    end
  end
  
  def output
    self.write_attributes(
      description: valid? ? source.full_description(self) : I18n.t("game_state.error"),
      hint: valid? ? source.full_hint(self) : nil
    )
  end
end
