class Command
  include Mongoid::Document
  field :action, type: String
  field :object_name, type: String
  embedded_in :game_state
  
  delegate :current_room, :game_save, to: :game_state
  
  class VariablesSatisfiedValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add attribute, "does not satisfy all variables" unless value && value.satisfied?(record.game_save)
    end
  end
  
  with_options if: :current_command? do |current|
    current.validates :referent, presence: true, variables_satisfied: true
    current.validates :event, presence: true, variables_satisfied: true
  end
  
  def parse(command_line)
    a, *on = command_line.split
    self.action = current_room.valid_event_actions[a.try(:downcase)]
    self.object_name = on.join(" ")
  end
  
  def referent
    @referent ||= current_room.objects.where(name: /#{object_name}/i).first
  end
  
  def event
    @event ||= referent ? referent.events.where(action: action).first : nil
  end
  
  def to_s
    "#{action} #{referent.name}"
  end
private
  def current_command?
    game_state == game_save.game_states.last
  end
end
