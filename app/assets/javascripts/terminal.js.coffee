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
    
    # Ascertains whether a section has unread entries, and marksup accordingly.
    update_unread_entries = (section) ->
      tab = "##{section}_tab"
      if $("##{section} .have-not-read").length > 0
        $(tab).addClass("unread-entries")
      else
        $(tab).removeClass("unread-entries")
        
    update_unread_entries("database")
    
    # A handler for marking database entries as read; also opens and closes entries.
    $("#database dt").live "click", ->
      if $(this).hasClass "have-not-read"
        id = this.id.replace(/^entry-/, '')
        read_entry_path = $("meta[name='read_entry_path']").attr("content")
        $.post read_entry_path, {entry_name: id}, (data) =>
          $(this).removeClass("have-not-read").addClass("have-read")
          update_unread_entries("database")
      $(this).toggleClass("opened")
      $(this).next("dd").toggleClass("opened")
    
    # A handler for updating the UI based off of how the server responded to the executed command.
    $("#terminal-command-line form").on "ajax:success", (event, data, status, xhr) ->
      if data['moved_to_room']
        $("#history").html(data['description'])
      else
        $("#history").append(data['description'])
      if data['entry']?
        next_entry = $("#entry-#{data['entry']['before']}")
        if next_entry.length > 0
          next_entry.before(data['entry']['info'])
        else
          $("#database").append(data['entry']['info'])
        update_unread_entries("database")
      $("#location").html(data['world_map']) if data['moved_to_room']
      $("#command_line").val("")
      position = $("##{data['id']}").position()
      $("#history").scrollTop(position.top)