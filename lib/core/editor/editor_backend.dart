import 'package:flutter/widgets.dart';
import 'package:mycelium/core/editor/editor_command.dart';
import 'package:mycelium/core/editor/editor_event.dart';

abstract class EditorBackend {
  Widget buildWidget(BuildContext context);

  Stream<EditorEvent> get events;

  void handleCommand(EditorCommand command);

  void dispose();
}
