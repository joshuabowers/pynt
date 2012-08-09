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
    class Commenter
      comment_line: (s) -> "##{s}"
      uncomment_line: (s) -> s.replace(/^#/, '')
      is_commented: (s) -> s.match(/^#/)?
      handle_line: (s) =>
        if this.is_commented(s)
          this.uncomment_line(s)
        else
          this.comment_line(s)
    commenter = new Commenter
    editor = CodeMirror.fromTextArea $("#room_yaml")[0],
      # mode: "yamldown",
      theme: "lesser-dark", 
      lineNumbers: true,
      extraKeys:
        "Cmd-Backspace": "deleteLine"
        "Cmd-/": (cm) ->
          if cm.somethingSelected()
            cm.replaceSelection _.map(cm.getSelection().split("\n"), commenter.handle_line).join("\n")
          else
            cursor = cm.getCursor(false)
            cm.setLine cursor.line, commenter.handle_line(cm.getLine(cursor.line))
        "Cmd-Enter": (cm) ->
          CodeMirror.commands["goLineEnd"](cm)
          CodeMirror.commands["newlineAndIndent"](cm)