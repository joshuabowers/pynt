class GameState
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :game_save
  field :description, type: String
  field :hint, type: String
  field :added_item_id, type: Moped::BSON::ObjectId
  field :removed_item_id, type: Moped::BSON::ObjectId
  field :updated_variables, type: Hash
  field :moved_to_room_id, type: Moped::BSON::ObjectId
  embeds_one :command
  embeds_one :entry, as: :definable
  # embeds_one :removed_item, as: :inventory, class_name: "Item"
  
  delegate :items, :variables, :current_room, :game, to: :game_save
  delegate :referent, :event, to: :command
    
  def moved_to_room?
    self.moved_to_room_id.present?
  end
  
  def added_item
    items.find(self.added_item_id) if self.added_item_id
  end
  
  def removed_item
    items.find(self.removed_item_id) if self.removed_item_id
  end
  
  def handle(command_line)
    self.build_command.parse(command_line)
    command_valid, error_message = false, nil
    begin
      if command_valid = valid?
        modify_variables
        clone_entry
        update_inventory
        enter_room(referent.destination) if event.change_location
        cache_modified_variables
      end
    rescue Exception => e
      error_message = e.to_s
    ensure
      output(command_valid, error_message)
    end
  end
  
  def start_game(starting_room)
    enter_room(starting_room)
    cache_modified_variables
    output(true)
  end
  
  def source
    @source ||= moved_to_room? ? current_room : event
  end
  
  def locate_widget(widget_name)
    items.in_inventory.where(name: /#{widget_name}/i).first ||
    items.in_current_room(current_room).where(name: /#{widget_name}/i).first ||
    current_room.recursive_where(name: /#{widget_name}/i, game_state: self).first
  end
private
  def enter_room(destination)
    game_save.update_visited_rooms(current_room, destination)
    game_save.current_room_id = destination.id
    self.variables["entered-rooms"][destination.parameterized_name] ||= 0
    self.variables["entered-rooms"][destination.parameterized_name] += 1
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
    event.description.try(:nested_description_of_type, self, Entry).tap do |entry|
      if entry
        self.entry = entry.clone
        previous_entry = game_save.entries.where(name: self.entry.name).first
        if previous_entry
          if previous_entry.description.to_s(self) != self.entry.description.to_s(self)
            self.entry = previous_entry.tap do |e|
              e.description = self.entry.description
              e.updated = true
              e.read = false
            end
          else
            self.entry = nil
          end
        else
          game_save.entries << self.entry.clone
        end
      end
    end
  end
  
  def update_inventory
    case
    when event.add_to_inventory
      unless items.where(path: referent.path).first
        items << referent.clone.tap do |item|
          self.added_item_id = item.id
          item.move_to_inventory
          variables["items"][item.path] = true
        end
      else
        raise I18n.t("inventory.already_have")
      end
    when event.remove_from_inventory
      unless items.in_inventory.where(path: referent.path).first
        items.where(path: referent.path).first.tap do |item|
          self.removed_item_id = item.id
          item.move_to(current_room)
          variables["items"][item.path] = false
        end
      else
        raise I18n.t("inventory.no_longer_have")
      end
    end
  end
  
  def cache_modified_variables
    if game_save.variables_changed?
      old_variables, new_variables = *game_save.variables_change.map(&:to_a)
      self.updated_variables = Hash[*(new_variables - old_variables).flatten]
    end
  end
  
  def output(command_valid, error_message = nil)
    self.write_attributes(
      description: command_valid ? source.full_description(self) : (error_message || I18n.t("game_state.error")),
      hint: command_valid ? source.full_hint(self) : nil
    )
  end
end
