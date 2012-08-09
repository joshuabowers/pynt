class TerminalController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @game = Game.where(parameterized_title: params['title']).first
    if @game
      @game_save = @game.load_last_save_for(current_user)
    else
      redirect_to root_path, alert: "How did you get here? Couldn't find: #{params['title']}"
    end
  end

  def execute
    @game = Game.find(params['game_id'])
    @command_line = params['command_line']
    @current_state = @game.execute(@command_line, current_user)
    data = {
      id: "gs#{@current_state.id.to_s}",
      moved_to_room: @current_state.moved_to_room?,
      description: render_to_string(partial: 'game_state', layout: false, object: @current_state),
      world_map: @current_state.moved_to_room? ? @current_state.game_save.generate_map : nil,
      entry: @current_state.event ? {
        info: render_to_string(partial: 'entry', layout: false, object: @current_state.event),
        before: @current_state.game_save.next_event_name_after(@current_state.event)
        } : nil
    }
    respond_to do |format|
      format.json { render json: data.to_json }
    end
  end
end
