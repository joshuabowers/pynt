class TerminalController < ApplicationController
  def index
  end

  def execute
    @command_line = params['command_line']
  end
end
