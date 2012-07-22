class TerminalController < ApplicationController
  before_filter :authenticate_user!
  
  # Essentially, should do something like:
  # @game = Game.where(title: params['title'])
  # @current_state = @game.load_last_save_for(current_user)
  # which would return a State object, to populate the terminal
  def index
    @game = Game.where(parameterized_title: params['title']).first
    if @game
      @current_state = @game.load_last_save_for(current_user)
    else
      redirect_to root_path, alert: "How did you get here? Couldn't find: #{params['title']}"
    end
  end

  # Again, like the above, this would be something like:
  # @game = Game.find(params['game_id'])
  # @current_state = @game.execute(@command_line)
  def execute
    @game = Game.find(params['game_id'])
    @command_line = params['command_line']
    @game.execute(@command_line, current_user)
  end
end
