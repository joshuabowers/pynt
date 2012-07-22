class TerminalController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @game = Game.where(parameterized_title: params['title']).first
    if @game
      @current_state = @game.load_last_save_for(current_user)
    else
      redirect_to root_path, alert: "How did you get here? Couldn't find: #{params['title']}"
    end
  end

  def execute
    @game = Game.find(params['game_id'])
    @command_line = params['command_line']
    @game.execute(@command_line, current_user)
  end
end
