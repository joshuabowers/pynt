class Item < Widget
  field :current_location, type: String
  embedded_in :inventory, polymorphic: true
  before_save :update_location
  
  scope :in_inventory, where(current_location: "inventory")
  scope :in_current_room, lambda {|current_room| where(:current_location => /^#{current_room.path}/)}
  
  def move_to_inventory
    self.current_location = "inventory"
  end
  
  def move_to(widget)
    self.current_location = widget.path
  end
private
  def update_location
    self.current_location = self.parent_widget.try(:path) unless self.current_location
  end
end
