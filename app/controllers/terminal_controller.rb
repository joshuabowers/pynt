class TerminalController < ApplicationController
  before_filter :authenticate_user!
  
  # Essentially, should do something like:
  # @game = Game.where(title: params['title'])
  # @current_state = @game.load_last_save_for(current_user)
  # which would return a State object, to populate the terminal
  def index
  end

  # Again, like the above, this would be something like:
  # @game = Game.find(params['game_id'])
  # @current_state = @game.execute(@command_line)
  def execute
    @command_line = params['command_line']
  end
end
