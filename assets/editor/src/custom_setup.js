import { EditorState } from "@codemirror/state"
import { defaultKeymap, historyKeymap } from "@codemirror/commands"
import { highlightSpecialChars, drawSelection, keymap } from "@codemirror/view"
import { syntaxHighlighting, defaultHighlightStyle } from "@codemirror/language"

export const customMinimalSetup = [
  highlightSpecialChars(),
  drawSelection(),
  EditorState.allowMultipleSelections.of(true),
  syntaxHighlighting(defaultHighlightStyle, { fallback: true }),
  keymap.of([
    ...defaultKeymap,
    ...historyKeymap,
  ])
];
