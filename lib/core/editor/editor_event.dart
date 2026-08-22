sealed class EditorEvent {
  const EditorEvent();
}

class TextChanged extends EditorEvent {
  final String content;

  const TextChanged(this.content);
}

class SelectionChanged extends EditorEvent {
  final int base;
  final int extent;

  const SelectionChanged(this.base, this.extent);
}

class EditorFocused extends EditorEvent {
  const EditorFocused();
}

class HistoryChanged extends EditorEvent {
  final bool canUndo;
  final bool canRedo;

  const HistoryChanged(this.canUndo, this.canRedo);
}
