sealed class EditorEvent {
  const EditorEvent();
}

class TextChanged extends EditorEvent {
  final String Function() getText;

  const TextChanged(this.getText);
}

class SelectionChanged extends EditorEvent {
  final int? Function() getBase;
  final int? Function() getExtent;
  final bool hasSelection;

  const SelectionChanged(this.getBase, this.getExtent,
      {this.hasSelection = false});
}

class EditorFocused extends EditorEvent {
  const EditorFocused();
}

class HistoryChanged extends EditorEvent {
  final bool canUndo;
  final bool canRedo;

  const HistoryChanged(this.canUndo, this.canRedo);
}
