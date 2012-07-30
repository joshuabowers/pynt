class Command
  include Mongoid::Document
  field :action, type: String
  field :referent, type: String
  
  def self.parse(command_line, room)
    action, *referent = command_line.split
    Command.new(action: room.valid_event_actions[action.downcase], referent: referent.join(" "))
  end
  
  def to_s
    "#{action} #{referent}"
  end
end
