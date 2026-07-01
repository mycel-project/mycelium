import './style.css'
import { EditorView, minimalSetup } from "codemirror"
import { EditorState, Compartment } from "@codemirror/state"
import { undo, redo, history, undoDepth, redoDepth } from "@codemirror/commands"
import { Table } from '@lezer/markdown';
import { markdown } from "@codemirror/lang-markdown"
import katex from "katex"
import "katex/dist/katex.min.css"
window.katex = katex
import {
  livePreviewPlugin,
  markdownStylePlugin,
  editorTheme,
  mouseSelectingField,
  collapseOnSelectionFacet,
    setMouseSelecting,
    linkPlugin,
    imageField,
      mathPlugin,
  blockMathField,
  tableField,
  tableEditorPlugin,
  codeBlockField,
} from 'codemirror-live-markdown';
import { githubLight, githubDark } from '@uiw/codemirror-theme-github';

// Keyboard/cursor focus
const editableCompartment = new Compartment()
const attributesCompartment = new Compartment()

const updateListener = EditorView.updateListener.of((update) => {
  if (window.flutter_inappwebview && typeof window.flutter_inappwebview.callHandler === 'function') {
    if (update.docChanged) {
      window.flutter_inappwebview.callHandler('onTextChange', update.state.doc.toString());
      window.flutter_inappwebview.callHandler('onHistoryChange', {
        canUndo: undoDepth(update.state) > 0,
        canRedo: redoDepth(update.state) > 0
      });
    }
    
    if (update.selectionSet) {
      const sel = update.state.selection.main;
      window.flutter_inappwebview.callHandler('onSelectionChange', {
        base: sel.anchor,
        extent: sel.head
      });
    }

    if (update.focusChanged && update.view.hasFocus) {
      window.flutter_inappwebview.callHandler('onEditorFocus');
    }
  }
});

const myExtensions = [
    minimalSetup,
    EditorView.lineWrapping,
    markdown({ extensions: [Table] }),
    updateListener,
    editableCompartment.of(EditorView.editable.of(true)),
    attributesCompartment.of(EditorView.contentAttributes.of({})),
    history(),
    collapseOnSelectionFacet.of(true),
    mouseSelectingField,
    livePreviewPlugin,
    markdownStylePlugin,
    editorTheme,
    githubLight,
    imageField(),
    linkPlugin(),
    mathPlugin,                      
    blockMathField,                    
    tableField,                        
    tableEditorPlugin(),               
    codeBlockField({ copyButton: false }),
]

const editor = new EditorView({
  doc: "",
  extensions: myExtensions,
  parent: document.getElementById('app')
})

editor.contentDOM.addEventListener('mousedown', () => {
  editor.dispatch({ effects: setMouseSelecting.of(true) });
});
document.addEventListener('mouseup', () => {
  requestAnimationFrame(() => {
    editor.dispatch({ effects: setMouseSelecting.of(false) });
  });
});

window.myceliumEditor = {  
  setDoc: (text, clearHistory, cursorPos) => {
    const scroller = editor.scrollDOM;
    const prevScroll = scroller.scrollTop;

    if (clearHistory) {
      editor.setState(EditorState.create({
        doc: text,
        extensions: myExtensions
      }));
    } else {
      const oldText = editor.state.doc.toString();
      if (oldText !== text) {
        let start = 0;
        while (start < oldText.length && start < text.length && oldText.charCodeAt(start) === text.charCodeAt(start)) {
          start++;
        }
        let endOld = oldText.length - 1;
        let endNew = text.length - 1;
        while (endOld >= start && endNew >= start && oldText.charCodeAt(endOld) === text.charCodeAt(endNew)) {
          endOld--;
          endNew--;
        }
        editor.dispatch({
          changes: { from: start, to: endOld + 1, insert: text.slice(start, endNew + 1) },
        });
      }
    }

    if (cursorPos !== undefined && cursorPos !== null && cursorPos >= 0 && cursorPos <= text.length) {
      editor.dispatch({ selection: { anchor: cursorPos, head: cursorPos } });
    }

    scroller.scrollTop = prevScroll;
  },
  // Keyboard/cursor focus
  setMode: (isLocked, showKeyboard, requestFocus) => {
    editor.dispatch({
      effects: [
        editableCompartment.reconfigure(EditorView.editable.of(!isLocked)),
        attributesCompartment.reconfigure(EditorView.contentAttributes.of(
          (!showKeyboard && !isLocked) ? { inputmode: "none" } : {}
        ))
      ]
    });
    if (requestFocus && !isLocked) {
      if (document.activeElement) document.activeElement.blur();
      setTimeout(() => editor.focus(), 50);
    }
  },
  blur: () => {
    if (document.activeElement) document.activeElement.blur();
  },
  undo: () => { undo(editor) },
  redo: () => { redo(editor) },
  scrollToOffset: (offset) => {
    if (offset >= 0 && offset <= editor.state.doc.length) {
      editor.dispatch({ effects: EditorView.scrollIntoView(offset, { y: 'start' }) });
    }
  }
}

window.addEventListener("flutterInAppWebViewPlatformReady",
  function(event) {
      window.flutter_inappwebview.callHandler('onEditorReady');
});
