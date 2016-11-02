{CompositeDisposable} = require 'atom'

module.exports = AtomHungryBackspace =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-hungry-backspace:toggle': => @toggle()

  deactivate: ->
    @subscriptions.dispose()

  toggle: ->
    console.log 'AtomHungryBackspace was toggled!'
