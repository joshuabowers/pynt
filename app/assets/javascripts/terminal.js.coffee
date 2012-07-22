# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

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