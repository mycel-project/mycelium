import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mycelium/data/models/outline_entry.dart';

// ClaudeAI
// Can't get auto-scroll to work cleanly.... With a traditional ListView, it doesn't scroll beyond a certain size, so a hacky technique is used by setting a high cacheExtent in ListView.builder.
class OutlineSheet extends StatefulWidget {
  final List<OutlineEntry>? entries;
  final void Function(int offset) onTap;
  final int? offset;
  final void Function()? onRefresh;
  const OutlineSheet({
      super.key,
      this.offset,
      required this.entries,
      required this.onTap,
      this.onRefresh,
  });

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

    _keys = List.generate(widget.entries?.length ?? 0, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant OutlineSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.entries != oldWidget.entries) {
      setState(() {
          _keys = List.generate(widget.entries?.length ?? 0, (_) => GlobalKey());
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActive();
        _didInitialScroll = true;
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
        duration: _didInitialScroll
        ? const Duration(milliseconds: 200)
        : Duration.zero ,
        curve: Curves.easeOut,
        alignment: 0.5,
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
        child: Center(child: Text("No headings")),
      );
    }

    final activeEntry = e.lastWhere(
      (entry) => entry.offset <= (widget.offset ?? 0),
      orElse: () => e.first,
    );

    return ListView.builder(
      controller: _scrollController,
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: e.length,
      scrollCacheExtent: ScrollCacheExtent.pixels(20000),
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
              await Future.delayed(const Duration(milliseconds: 200));
              if (mounted) {
                setState(() {
                    _isProgrammaticScroll = false;
                });
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: isActive
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                  : null,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: entry.level >= 3
                      ? 8.0 + (entry.level - 3) * 12.0
                      : 8.0,
                      right: 16,
                      top: entry.level == 1 ? 14 : 8,
                      bottom: entry.level == 1 ? 14 : 8,
                    ),
                    child: Row(
                      children: [
                        if (entry.level <= 2)
                        Container(
                          width: 3,
                          height: 18,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: entry.level == 1
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                        else
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(right: 10, left: 3),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.title,
                            style: TextStyle(
                              fontSize: (15 - (entry.level - 1) * 0.8).clamp(
                                12.0,
                                15.0,
                              ),
                              fontWeight: entry.level == 1
                              ? FontWeight.w600
                              : FontWeight.normal,
                              color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(
                                alpha: entry.level >= 3 ? 0.65 : 1.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (entry.level == 1)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Theme.of(
                    context,
                  ).dividerColor.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget buildOutlineSheet(
  BuildContext context, {
    required List<OutlineEntry>? entries,
    required void Function(int offset) onTap,
    void Function()? onRefresh,
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
