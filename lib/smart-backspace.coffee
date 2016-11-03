{CompositeDisposable} = require 'atom'

###*
 * Checks if given string contains anything except spaces and tabs
 * @param  {string}  str the string to check
 * @return {Boolean}     true if the string is blank
###
isStringBlank = (str) -> str.trim().length == 0

module.exports = AtomHungryBackspace =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', 'smart-backspace:backspace': @backspace

  deactivate: ->
    @subscriptions.dispose()

  backspace: (event) ->
    editor = atom.workspace.getActiveTextEditor()
    editorView = atom.views.getView(editor)
    
    if editor and editorView.classList.contains 'is-focused' # Has the editor focus?
      selections = editor.getSelections()
      
      if selections.length == 1 and selections[0].isEmpty()
        cursorPositions = editor.getCursorBufferPositions()
        
        if cursorPositions.length == 1 # Only when using one cursor
          cursorPosition = cursorPositions[0]
          currRow = cursorPosition.row
          prevRow = currRow - 1
          
          if prevRow > 0 # No hunger in the first row
            currIndentation = editor.indentationForBufferRow currRow
            prevIndentation = editor.indentationForBufferRow prevRow
            
            if currIndentation >= prevIndentation
              currLine = editor.lineTextForBufferRow(currRow).substr 0, cursorPosition.column
              prevLine = editor.lineTextForBufferRow prevRow

              if isStringBlank(currLine) and isStringBlank(prevLine)
                missingIndentation = currIndentation - prevIndentation
                
                # Perform smart backspace
                editor.transact () ->
                  editor.moveUp()
                  editor.insertText editor.getTabText() for [1..missingIndentation] if missingIndentation
                  editor.selectDown()
                  editor.backspace()
                return

              
    # if we didn't
    atom.commands.dispatch(event.target, 'core:backspace')
