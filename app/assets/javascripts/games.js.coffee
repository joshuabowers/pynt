# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if $("meta[name='context']").attr("content") == "games"
    world_map_path = $("meta[name='world_map_path']").attr("content")
    $("#game_starting_room_id").change ->
      $.post world_map_path, {starting_room: $(this).val()}, (data) ->
        $("#world-map .data").html data['world_map']