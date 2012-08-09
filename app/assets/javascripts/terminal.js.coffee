$ ->
  if $("meta[name='context']").attr("content") == "terminal"
    default_tab = "#database"
  
    # Sets up a handler to ensure that the current sidebar tab is correctly marked up
    $("#main aside nav a").click ->
      $("#main aside nav a.current").removeClass "current"
      $(this).addClass "current"
    
    # Invokes above handler, to ensure that the tab is selected on page load.
    window.location.hash = default_tab unless window.location.hash
    $("#{window.location.hash || default_tab}_tab").click()
    
    $("#database dt").live "click", ->
      $(this).next("dd").toggleClass("opened")
    
    # A handler for updating the UI based off of how the server responded to the executed command.
    $("#terminal-command-line form").on "ajax:success", (event, data, status, xhr) ->
      if data['moved_to_room']
        $("#history").html(data['description'])
      else
        $("#history").append(data['description'])
      $("#location").html(data['world_map']) if data['moved_to_room']
      $("#command_line").val("")
      position = $("##{data['id']}").position()
      $("#history").scrollTop(position.top)