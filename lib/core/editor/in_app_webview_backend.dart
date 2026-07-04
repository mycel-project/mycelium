import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mycelium/core/editor/editor_backend.dart';
import 'package:mycelium/core/editor/editor_command.dart';
import 'package:mycelium/core/editor/editor_event.dart';

class InAppWebViewBackend implements EditorBackend {
  InAppWebViewController? _controller;

  final _eventsController = StreamController<EditorEvent>.broadcast();

  @override
  Stream<EditorEvent> get events => _eventsController.stream;

  @override
  Widget buildWidget(BuildContext context) {
    return InAppWebView(
      initialSettings: InAppWebViewSettings(transparentBackground: true),
      initialFile: "assets/editor/dist/index.html",
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<VerticalDragGestureRecognizer>(
          VerticalDragGestureRecognizer.new,
        ),
        Factory<LongPressGestureRecognizer>(
          () => LongPressGestureRecognizer(
            duration: const Duration(milliseconds: 250),
          ),
        ),
      },
      onWebViewCreated: (controller) {
        _controller = controller;

        controller.addJavaScriptHandler(
          handlerName: 'onEditorFocus',
          callback: (args) {
            _eventsController.add(const EditorFocused());
          },
        );
        controller.addJavaScriptHandler(
          handlerName: 'onTextChange',
          callback: (args) {
            if (args.isNotEmpty) {
              _eventsController.add(TextChanged(args[0] as String));
            }
          },
        );
        controller.addJavaScriptHandler(
          handlerName: 'onSelectionChange',
          callback: (args) {
            if (args.isNotEmpty) {
              final data = Map<String, dynamic>.from(args[0] as Map);
              _eventsController.add(
                SelectionChanged(data['base'] as int, data['extent'] as int),
              );
            }
          },
        );
        controller.addJavaScriptHandler(
          handlerName: 'onHistoryChange',
          callback: (args) {
            if (args.isNotEmpty) {
              final data = Map<String, dynamic>.from(args[0] as Map);
              _eventsController.add(
                HistoryChanged(
                  data['canUndo'] as bool,
                  data['canRedo'] as bool,
                ),
              );
            }
          },
        );
      },
      onLoadStop: (controller, url) async {
        _eventsController.add(const EditorReady());
      },
    );
  }

  @override
  void handleCommand(EditorCommand command) {
    switch (command) {
      case SetDoc(:final content, :final cursor, :final clearHistory):
        debugPrint(
          "[BACKEND] SetDoc: content.length=${content.length} clearHistory=$clearHistory cursor=$cursor controller=${_controller != null}",
        );
        _controller?.evaluateJavascript(
          source:
              "window.myceliumEditor.setDoc(${jsonEncode(content)}, $clearHistory, ${cursor != null ? cursor.toString() : 'null'});",
        );
      case SetMode(:final isLocked, :final showKeyboard, :final requestFocus):
        _controller?.evaluateJavascript(
          source:
              "window.myceliumEditor.setMode(${isLocked}, ${showKeyboard}, ${requestFocus});",
        );
      case Undo():
        _controller?.evaluateJavascript(
          source: "window.myceliumEditor.undo();",
        );
      case Redo():
        _controller?.evaluateJavascript(
          source: "window.myceliumEditor.redo();",
        );
      case ScrollTo(:final offset, :final margin):
        _controller?.evaluateJavascript(
          source: "window.myceliumEditor.scrollToOffset(${offset}, ${margin});",
        );
      case Blur():
        _controller?.evaluateJavascript(
          source:
              "window.myceliumEditor.blur(); window.myceliumEditor.clearSelection();",
        );
        if (!kIsWeb) {
          _controller?.clearFocus();
        }
      case ClearSelection():
        _controller?.evaluateJavascript(
          source: "window.myceliumEditor.clearSelection();",
        );
    }
  }

  @override
  void dispose() {
    _eventsController.close();
    _controller = null;
  }
}
