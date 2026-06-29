import './style.css'
import { EditorView, basicSetup } from "codemirror"
import { markdown } from "@codemirror/lang-markdown"

const editor = new EditorView({
  doc: "# Mycelium",
  extensions: [
    basicSetup,
    markdown(),
  ],
  parent: document.getElementById('app')
})

window.myceliumEditor = {
  getDoc: () => editor.state.doc.toString(),
  
  setDoc: (text) => {
    editor.dispatch({
      changes: { from: 0, to: editor.state.doc.length, insert: text }
    })
  }
}
