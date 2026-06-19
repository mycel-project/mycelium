import "dart:developer";

import "package:markdown_mycel_fork/markdown.dart";

String astToString(List<Node> nodes, {int indent = 0}) {
  final buffer = StringBuffer();
  final prefix = '│  ' * indent;

  for (final node in nodes) {
    final label = switch (node) {
      Element e => '├─ <${e.tag}> "${e.textContent}" attrs: ${e.attributes}',
      Text t => '├─ TEXT: "${t.textContent}"',
      _ => '├─ [unknown]',
    };

    buffer.writeln('$prefix$label');

    if (node is Element && node.children != null) {
      buffer.write(astToString(node.children!, indent: indent + 1));
    }
  }

  return buffer.toString();
}

void printAst(List<Node> nodes, {int indent = 0}) {
  log("\n");
  log(astToString(nodes, indent: indent));
}
