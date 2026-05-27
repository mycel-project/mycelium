import 'package:flutter/material.dart';
import 'package:mycelium/data/models/outline_entry.dart';

// ClaudeAI
// Can't get auto-scroll to work cleanly.... With a traditional ListView, it doesn't scroll beyond a certain size, so a hacky technique is used by setting a high cacheExtent in ListView.builder.
class OutlineSheet extends StatefulWidget {
  final List<OutlineEntry>? entries;
  final void Function(int offset) onTap;
  final int? offset;
  final Future<List<OutlineEntry>?> Function()? onRefresh;
  const OutlineSheet({super.key, this.offset, required this.entries, required this.onTap, this.onRefresh});

  @override
  State<OutlineSheet> createState() => _OutlineSheetState();
}

class _OutlineSheetState extends State<OutlineSheet> {
  final ScrollController _scrollController = ScrollController();

  var _keys = <GlobalKey>[];
  bool _didInitialScroll = false;

  bool _isProgrammaticScroll = false;

  @override
  void initState() {
    super.initState();

    _keys = List.generate(
      widget.entries?.length ?? 0,
      (_) => GlobalKey(),
    );
  }

  @override
  void didUpdateWidget(covariant OutlineSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.entries != oldWidget.entries) {
      setState(() {
          _keys = List.generate(
            widget.entries?.length ?? 0,
            (_) => GlobalKey(),
          );
      });
    }

    if (widget.offset != oldWidget.offset && !_isProgrammaticScroll) {
      _scrollToActive();
    }
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
        alignment: 0.5
      );
      return;
    }

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

    return Stack(
      children: [
        Positioned.fill(
          child: ListView.builder(
            controller: _scrollController,
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.only(bottom: 12), 
            itemCount: e.length,
            cacheExtent: 20000,
            itemBuilder: (context, i) {
              final entry = e[i];
              final isActive = entry == activeEntry;

              return Material(
                color: Colors.transparent, 
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                key: _keys[i],
                onTap: () async {
                  setState(() {
                    _isProgrammaticScroll = true;
                  });
                  widget.onTap(entry.offset);
                  _tryScroll(i);
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (mounted) {
                    setState(() {
                      _isProgrammaticScroll = false;
                    });
                  }
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
                      fontWeight: entry.level == 1
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh), 
                tooltip: 'Refresh outline',
                onPressed: () {
                  if (widget.onRefresh != null) {
                    widget.onRefresh!();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget buildOutlineSheet(
  BuildContext context, {
  required List<OutlineEntry>? entries,
  required void Function(int offset) onTap,
  Future<List<OutlineEntry>?> Function()? onRefresh,
  int? currentOffset,
  double height = 400, 
}) {
  return SizedBox(
    width: double.infinity, 
    height: height,
    child: OutlineSheet(
      entries: entries,
      onTap: onTap,
      offset: currentOffset,
      onRefresh: onRefresh,
    ),
  );
}
