import 'package:flutter/material.dart';
import 'package:mycelium/data/models/outline_entry.dart';
import 'package:mycelium/ui/widgets/adaptative_sheet.dart';


class OutlineSheet extends StatelessWidget {
  final List<OutlineEntry>? entries;
  final void Function(int offset) onTap;

  const OutlineSheet({
    super.key,
    required this.entries,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final e = entries;
    if (e == null || e.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text("No headings found")),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: e.length,
      itemBuilder: (context, i) {
        final entry = e[i];
        return InkWell(
          onTap: () {
            onTap(entry.offset);
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0 + (entry.level - 1) * 16.0,
              right: 16,
              top: 10,
              bottom: 10,
            ),
            child: Text(
              entry.title,
              style: TextStyle(
                fontSize: 16 - (entry.level - 1) * 1.5,
                fontWeight: entry.level == 1 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<void> showOutlineSheet(
  BuildContext context, {
  required List<OutlineEntry>? entries,
  required void Function(int offset) onTap,
}) async {
  showAdaptiveSheet(
    context: context,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height / 2,
      ),
      child: OutlineSheet(entries: entries, onTap: onTap),
    ),
  );
}
