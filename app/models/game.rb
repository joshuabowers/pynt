class Game
  include Mongoid::Document
  field :title, type: String
  field :parameterized_title, type: String
  field :description, type: String
  field :genre, type: String
  
  before_save :parameterize_title
  
  def load_last_save_for(user)
    nil
  end
  
  def execute(command_line, user)
    nil
  end
  
private
  def parameterize_title
    self.parameterized_title = self.title.parameterize
  end
end
