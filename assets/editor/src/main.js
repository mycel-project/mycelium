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
  
    setDoc: (text) => {//, cursor, resetScroll) => {
 //   const scrollY = window.scrollY;
    editor.dispatch({
      changes: { from: 0, to: editor.state.doc.length, insert: text },
      //selection: cursor !== undefined && cursor !== null ? { anchor: cursor } : undefined
    });
    // if (resetScroll) {
    //   window.scrollTo(0, 0);
    // } else {
    //   window.scrollTo(0, scrollY);
    //   requestAnimationFrame(() => {
    //     window.scrollTo(0, scrollY);
    //     setTimeout(() => window.scrollTo(0, scrollY), 10);
    //   });
    //}
  },
}
