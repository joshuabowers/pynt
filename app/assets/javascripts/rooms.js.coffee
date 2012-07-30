# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if $("meta[name='context']").attr("content") == "rooms"
    # Hmm, this does not seem to be working properly, just yet. Curious.
    # CodeMirror.defineMode "yamldown", (config) ->
    #   CodeMirror.multiplexingMode CodeMirror.getMode(config, "text/x-yaml"),
    #     open: '<<',
    #     close: '>>',
    #     mode: CodeMirror.getMode(config, "text/plain"),
    #     delimStyle: "delimit"
    editor = CodeMirror.fromTextArea $("#room_yaml")[0],
      # mode: "yamldown",
      theme: "lesser-dark", 
      lineNumbers: true,
      extraKeys: {
        "Cmd-Delete": "deleteLine",
        "Cmd-Enter": (cm) ->
          CodeMirror.commands["goLineEnd"](cm)
          CodeMirror.commands["newlineAndIndent"](cm)
      }