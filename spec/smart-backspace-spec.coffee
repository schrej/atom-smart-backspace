AtomHungryBackspace = require '../lib/smart-backspace'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe 'SmartBackspace', ->
  [pkg] = []
  
  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('smart-backspace').then (p) ->
        pkg = p.mainModule
      
    waitsForPromise ->
      atom.packages.activatePackage 'language-text'
    
    workspaceElement = atom.views.getView atom.workspace
    jasmine.attachToDOM workspaceElement
  
  describe 'backspace', ->
    [newRow, newColumn, newIndentation, editor, editorView] = []
    
    backspace = ->
      atom.commands.dispatch editorView, 'smart-backspace:backspace'
      cursorPosition = editor.getCursorBufferPositions()[0]
      newRow = cursorPosition.row
      newColumn = cursorPosition.column
      newIndentation = editor.indentationForBufferRow newRow
          
    beforeEach ->
      waitsForPromise ->
        atom.workspace.open('sample.txt', {autoIndent: false}).then (o) ->
          editor = o
          editorView = atom.views.getView(editor)
    
    describe 'is smart when', ->
    
      it 'both lines are blank and equally indented', ->
        editor.setCursorBufferPosition row: 6, column: 4
        
        backspace()
        
        expect(newRow).toBe 5
        expect(newIndentation).toBe 2
      
      it 'both lines are blank and the above less indented', ->
        editor.setCursorBufferPosition row: 7, column: 6
        
        backspace()
        
        expect(newRow).toBe 6
        expect(newIndentation).toBe 3
      
      it 'indentation is equal or less, above is blank and left of cursor is blank with text on the right', ->
        editor.setCursorBufferPosition row: 4, column: 4
        
        backspace()
        
        expect(newRow).toBe 3
        expect(newIndentation).toBe 2
      
      it 'should and the above is the first line', ->
        editor.setCursorBufferPosition row: 1, column: 2
        
        backspace()
        
        expect(newRow).toBe 0
        expect(newIndentation).toBe 1
    
    describe 'is not smart when', ->
      
      it 'the line above is not blank', ->
        editor.setCursorBufferPosition row: 3, column: 4
        
        backspace()
        
        expect(newRow).toBe 3
        expect(newIndentation).toBe 1
      
      it 'left of cursor is not blank', ->
        editor.setCursorBufferPosition row: 2, column: 5
        
        backspace()
        
        expect(newRow).toBe 2
        expect(newColumn).toBe 4
      
      it 'line above is higher indented', ->
        editor.setCursorBufferPosition row: 8, column: 4
        
        backspace()
        
        expect(newRow).toBe 8
        expect(newIndentation).toBe 1
      
      it 'is in the first line', ->
        editor.setCursorBufferPosition row: 0, column: 2
        
        backspace()
        
        expect(newRow).toBe 0
        expect(newIndentation).toBe 0
