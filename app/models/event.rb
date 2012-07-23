class Event
  include Mongoid::Document
  field :action, type: String
  embedded_in :interactive, polymorphic: true
  
  def self.parse(command_line)
    nil
  end
end
