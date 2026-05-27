import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mycelium/data/models/outline_entry.dart';
import 'package:mycelium/ui/widgets/adaptative_sheet.dart';
import 'package:url_launcher/url_launcher.dart';


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

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(
            top: 48, 
            bottom: 12,
          ),
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
            );
          },
        ),
        
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.info_outline), 
            tooltip: 'Informations',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Information"),
                  content: Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        const TextSpan(
                          text: "Please note that clicking a heading may result in a slightly imprecise scroll position, and the highlighted heading may also vary slightly.\n\n",
                        ),
                        const TextSpan(
                          text: "See ",
                        ),
                        TextSpan(
                          text: "this GitHub issue", 
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary, 
                          ),
                          recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(
                              Uri.parse(
                                "https://github.com/mycel-project/mycelium/issues/1", 
                              ),
                            );
                          },
                        ),
                        const TextSpan(
                          text: " for more information about this behavior.",
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                )
              );
            },
          ),
        ),
      ],
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
