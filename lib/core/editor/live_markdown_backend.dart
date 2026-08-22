import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_live_markdown/flutter_live_markdown.dart';
import 'package:mycelium/core/editor/editor_backend.dart';
import 'package:mycelium/core/editor/editor_command.dart';
import 'package:mycelium/core/editor/editor_event.dart';

class LiveMarkdownBackend implements EditorBackend {
  final LiveMarkdownController _controller = LiveMarkdownController();
  final StreamController<EditorEvent> _eventStream =
      StreamController.broadcast();

  // flutter_live_markdown -> Mycelium. Translate package hook to EditorEvent that md_editor can recognize (and handle in _onBackendEvent).
  LiveMarkdownBackend() {
    _controller.onChange = () {
      _eventStream.add(TextChanged(() => _controller.text));
    };
    
    _controller.onSelectionChange = () {
      _eventStream.add(
        SelectionChanged(
          () => _controller.selectionStart, 
          () => _controller.selectionEnd,
          hasSelection: _controller.hasSelection,
        ),
      );
    };

    _controller.onFocusChange = (bool hasFocus) {
      if (hasFocus) {
        _eventStream.add(const EditorFocused());
      }
    };

    _controller.onHistoryChange = () {
      _eventStream.add(
        HistoryChanged(_controller.canUndo, _controller.canRedo),
      );
    };
  }

  @override
  Stream<EditorEvent> get events => _eventStream.stream;

  @override
  Widget buildWidget(BuildContext context) {
    return LiveMarkdownEditor(
      controller: _controller,
      deferToPointerUp: true,
      cursorInsideMarkers: true,
    );
  }

  // Mycelium -> flutter_live_markdown. Translate Mycelium actions to commands that the package recognize.
  @override
  void handleCommand(EditorCommand command) {
    switch (command) {
      case SetDoc(:final content, :final cursor):
        // clear undo history by default
        _controller.replaceContent(content, cursor: cursor);
      case Undo():
        _controller.undo();
      case Redo():
        _controller.redo();
      case SetMode(:final readOnly, :final requestFocus):
        _controller.setReadOnly(readOnly);
        if (requestFocus) {
          _controller.requestFocus();
        }
      case Blur():
        _controller.blur();
      case ClearSelection():
        _controller.clearSelection();
      case ScrollTo(:final offset):
        _controller.scrollTo(offset);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _eventStream.close();
  }
}
