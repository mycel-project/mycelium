import './style.css'
import { EditorView, minimalSetup } from "codemirror"
import { markdown } from "@codemirror/lang-markdown"

const editor = new EditorView({
  doc: "",
  extensions: [
      minimalSetup,
      EditorView.lineWrapping,
    markdown(),
  ],
  parent: document.getElementById('app')
})

window.myceliumEditor = {  
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

window.addEventListener("flutterInAppWebViewPlatformReady",
  function(event) {
      window.flutter_inappwebview.callHandler('onEditorReady');
});
