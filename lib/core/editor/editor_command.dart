sealed class EditorCommand {
  const EditorCommand();
}

class SetDoc extends EditorCommand {
  final String content;
  final int? cursor;
  final bool clearHistory;

  const SetDoc(this.content, {this.cursor, this.clearHistory = false});
}

class SetMode extends EditorCommand {
  final bool isLocked;
  final bool showKeyboard;
  final bool requestFocus;

  const SetMode(this.isLocked, this.showKeyboard, {this.requestFocus = false});
}

class Undo extends EditorCommand {
  const Undo();
}

class Redo extends EditorCommand {
  const Redo();
}

class ScrollTo extends EditorCommand {
  final int offset;
  final int margin;

  const ScrollTo(this.offset, {this.margin = 0});
}

class Blur extends EditorCommand {
  const Blur();
}

class ClearSelection extends EditorCommand {
  const ClearSelection();
}
