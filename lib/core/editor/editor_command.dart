sealed class EditorCommand {
  const EditorCommand();
}

class SetDoc extends EditorCommand {
  final String content;
  final int? cursor;

  const SetDoc(this.content, {this.cursor});
}

class SetMode extends EditorCommand {
  final bool readOnly;
  final bool requestFocus;

  const SetMode(this.readOnly, {this.requestFocus = false});
}

class Undo extends EditorCommand {
  const Undo();
}

class Redo extends EditorCommand {
  const Redo();
}

class ScrollTo extends EditorCommand {
  final int offset;

  const ScrollTo(this.offset);
}

class Blur extends EditorCommand {
  const Blur();
}

class ClearSelection extends EditorCommand {
  const ClearSelection();
}
