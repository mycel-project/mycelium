import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:live_markdown_editor/live_markdown_editor.dart';
import 'package:mycelium/core/editor/editor_backend.dart';
import 'package:mycelium/core/editor/editor_command.dart';
import 'package:mycelium/core/editor/editor_event.dart';

class LiveMarkdownBackend implements EditorBackend {
  final MarkdownEditorController _controller = MarkdownEditorController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final StreamController<EditorEvent> _eventStream =
      StreamController.broadcast();

  String _lastText = '';
  TextSelection _lastSelection = const TextSelection.collapsed(offset: -1);
  bool _lastCanUndo = false;
  bool _lastCanRedo = false;

  LiveMarkdownBackend() {
    _controller.addListener(_onControllerChanged);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _eventStream.add(const EditorFocused());
      }
    });
  }

  void _onControllerChanged() {
    if (_controller.text != _lastText) {
      _lastText = _controller.text;
      _eventStream.add(TextChanged(() => _lastText));
    }

    if (_controller.selection != _lastSelection) {
      _lastSelection = _controller.selection;
      _eventStream.add(
        SelectionChanged(
          () => _lastSelection.isValid ? _lastSelection.baseOffset : null,
          () => _lastSelection.isValid ? _lastSelection.extentOffset : null,
          hasSelection: _lastSelection.isValid && !_lastSelection.isCollapsed,
        ),
      );
    }

    if (_controller.canUndo != _lastCanUndo || _controller.canRedo != _lastCanRedo) {
      _lastCanUndo = _controller.canUndo;
      _lastCanRedo = _controller.canRedo;
      _eventStream.add(
        HistoryChanged(_controller.canUndo, _controller.canRedo),
      );
    }
  }

  @override
  Stream<EditorEvent> get events => _eventStream.stream;

  @override
  Widget buildWidget(BuildContext context) {
    return LiveMarkdownEditor(
        controller: _controller,
        focusNode: _focusNode,
        scrollController: _scrollController,
    );
  }

  @override
  void handleCommand(EditorCommand command) {
    switch (command) {
      case SetDoc(:final content, :final cursor):
        final currentSelection = _controller.selection;
        _controller.value = TextEditingValue(
          text: content,
          selection: cursor != null
              ? TextSelection.collapsed(offset: cursor)
              : (currentSelection.isValid && currentSelection.end <= content.length)
                  ? currentSelection
                  : const TextSelection.collapsed(offset: -1),
        );
      case Undo():
        _controller.undo();
      case Redo():
        _controller.redo();
      case SetMode(:final readOnly, :final requestFocus):
        _controller.mode =
            readOnly ? MarkdownEditorMode.read : MarkdownEditorMode.live;
        if (requestFocus) {
          _focusNode.requestFocus();
        }
      case Blur():
        _focusNode.unfocus();
      case ClearSelection():
        if (_controller.selection.isValid) {
          _controller.selection = TextSelection.collapsed(
            offset: _controller.selection.baseOffset,
          );
        }
      case ScrollTo(:final offset):
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(offset.toDouble());
        }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _eventStream.close();
  }
}

// Forme flutter_live_markdown
// class LiveMarkdownBackend implements EditorBackend {
//   final LiveMarkdownController _controller = LiveMarkdownController();
//   final StreamController<EditorEvent> _eventStream =
//       StreamController.broadcast();

//   // flutter_live_markdown -> Mycelium. Translate package hook to EditorEvent that md_editor can recognize (and handle in _onBackendEvent).
//   LiveMarkdownBackend() {
//     _controller.onChange = () {
//       _eventStream.add(TextChanged(() => _controller.text));
//     };
    
//     _controller.onSelectionChange = () {
//       _eventStream.add(
//         SelectionChanged(
//           () => _controller.selectionStart, 
//           () => _controller.selectionEnd,
//           hasSelection: _controller.hasSelection,
//         ),
//       );
//     };

//     _controller.onFocusChange = (bool hasFocus) {
//       if (hasFocus) {
//         _eventStream.add(const EditorFocused());
//       }
//     };

//     _controller.onHistoryChange = () {
//       _eventStream.add(
//         HistoryChanged(_controller.canUndo, _controller.canRedo),
//       );
//     };
//   }

//   @override
//   Stream<EditorEvent> get events => _eventStream.stream;

//   @override
//   Widget buildWidget(BuildContext context) {
//     return LiveMarkdownEditor(
//       controller: _controller,
//       deferToPointerUp: true,
//       cursorInsideMarkers: true,
//     );
//   }

//   // Mycelium -> flutter_live_markdown. Translate Mycelium actions to commands that the package recognize.
//   @override
//   void handleCommand(EditorCommand command) {
//     switch (command) {
//       case SetDoc(:final content, :final cursor):
//         // clear undo history by default
//         _controller.replaceContent(content, cursor: cursor);
//       case Undo():
//         _controller.undo();
//       case Redo():
//         _controller.redo();
//       case SetMode(:final readOnly, :final requestFocus):
//         _controller.setReadOnly(readOnly);
//         if (requestFocus) {
//           _controller.requestFocus();
//         }
//       case Blur():
//         _controller.blur();
//       case ClearSelection():
//         _controller.clearSelection();
//       case ScrollTo(:final offset):
//         _controller.scrollTo(offset);
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _eventStream.close();
//   }
// }
