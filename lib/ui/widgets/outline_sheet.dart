import 'package:flutter/material.dart';
import 'package:mycelium/data/models/outline_entry.dart';
import 'package:mycelium/ui/widgets/adaptative_sheet.dart';


// ClaudeAI
// Can't get auto-scroll to work cleanly.... With a traditional ListView, it doesn't scroll beyond a certain size, so a hacky technique is used by setting a high cacheExtent in ListView.builder.
class OutlineSheet extends StatefulWidget {
  final List<OutlineEntry>? entries;
  final void Function(int offset) onTap;
  final int? offset;
  const OutlineSheet({super.key, this.offset, required this.entries, required this.onTap});

  @override
  State<OutlineSheet> createState() => _OutlineSheetState();
}

class _OutlineSheetState extends State<OutlineSheet> {
  final ScrollController _scrollController = ScrollController();

  var _keys = <GlobalKey>[];
  bool _didInitialScroll = false;

  @override
  void initState() {
    super.initState();

    _keys = List.generate(
      widget.entries?.length ?? 0,
      (_) => GlobalKey(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didInitialScroll) return;
    _didInitialScroll = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActive();
    });
  }

  void _scrollToActive() {
    final e = widget.entries;
    if (e == null || e.isEmpty) return;

    final activeEntry = e.lastWhere(
      (entry) => entry.offset <= (widget.offset ?? 0),
      orElse: () => e.first,
    );

    final activeIndex = e.indexOf(activeEntry);

    _tryScroll(activeIndex);
  }

  void _tryScroll(int index) {
    if (!mounted) return;

    if (index >= _keys.length) return;

    final context = _keys[index].currentContext;

    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        alignment: 0.3,
      );
      return;
    }

    // Réessaye au frame suivant
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryScroll(index);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entries;

    if (e == null || e.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text("No headings found"),
        ),
      );
    }

    final activeEntry = e.lastWhere(
      (entry) => entry.offset <= (widget.offset ?? 0),
      orElse: () => e.first,
    );

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: e.length,
      cacheExtent: 20000, // To allow auto scroll on long lists
      itemBuilder: (context, i) {
        final entry = e[i];
        final isActive = entry == activeEntry;

        return InkWell(
          key: _keys[i],
          onTap: () {
            widget.onTap(entry.offset);
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: 16 + (entry.level - 1) * 16,
              right: 16,
              top: 10,
              bottom: 10,
            ),
            child: Text(
              entry.title,
              style: TextStyle(
                fontSize: 16 - (entry.level - 1) * 1.5,
                fontWeight: entry.level == 1
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color,
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
  int? currentOffset,
}) async {
  showAdaptiveSheet(
    context: context,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height / 2,
      ),
      child: OutlineSheet(
        entries: entries,
        onTap: onTap,
        offset: currentOffset,
      ),
    ),
  );
}
