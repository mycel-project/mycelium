import './style.css'
import { EditorView, minimalSetup } from "codemirror"
import { markdown } from "@codemirror/lang-markdown"

const updateListener = EditorView.updateListener.of((update) => {
  if (window.flutter_inappwebview && typeof window.flutter_inappwebview.callHandler === 'function') {
    if (update.docChanged) {
      window.flutter_inappwebview.callHandler('onTextChange', update.state.doc.toString());
    }
    
    if (update.selectionSet) {
      const sel = update.state.selection.main;
      window.flutter_inappwebview.callHandler('onSelectionChange', {
        base: sel.anchor,
        extent: sel.head
      });
    }
  }
});

const editor = new EditorView({
  doc: "",
  extensions: [
    minimalSetup,
    EditorView.lineWrapping,
    markdown(),
    updateListener
  ],
  parent: document.getElementById('app')
})

window.myceliumEditor = {  
  setDoc: (text) => {
    editor.dispatch({
      changes: { from: 0, to: editor.state.doc.length, insert: text },
    });
  },
}

window.addEventListener("flutterInAppWebViewPlatformReady",
  function(event) {
      window.flutter_inappwebview.callHandler('onEditorReady');
});
