import 'package:flutter/material.dart';
import 'package:mycelium/utils/device.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ActivityAction {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  ActivityAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
}

enum DesktopPosition { topBarLeft, topBarRight } // add burger if need space

enum MobilePosition { burger, appBarRight, bottomPanel }

class AdaptativeElement {
  final IconData icon;
  final String tooltip; // label in burger
  final VoidCallback onTap;
  final DesktopPosition? desktopPosition; // null = not shown on desktop
  final MobilePosition? mobilePosition; // null = not shown on mobile

  AdaptativeElement({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.desktopPosition,
    this.mobilePosition,
  });
}

class AdaptativeScaffold extends StatefulWidget {
  final Widget body;
  final Widget? leftPannel;
  final Widget? rightPannel;

  final List<ActivityAction>? activityActions; // for "activity bar"
  final List<AdaptativeElement>? adaptativeElements;

  final Widget? topBarContent;

  final bool? overrideIsDesktop; // for testing

  const AdaptativeScaffold({
    super.key,
    required this.body,
    this.leftPannel,
    this.rightPannel,
    this.activityActions,
    this.adaptativeElements,
    this.topBarContent,
    this.overrideIsDesktop,
  });

  @override
  State<AdaptativeScaffold> createState() => AdaptativeScaffoldState();
}

class AdaptativeScaffoldState extends State<AdaptativeScaffold> {
  bool _isLeftOpen = false;
  bool _isRightOpen = false;

  double _leftWidth = 250.0;
  double _rightWidth = 250.0;

  double _rawLeftWidth = 0.0;
  double _rawRightWidth = 0.0;

  bool _isDraggingLeft = false;
  bool _isDraggingRight = false;

  bool _isHoveringLeft = false;
  bool _isHoveringRight = false;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildResizeHandle({
    required bool isHovering,
    required bool isDragging,
    required ValueChanged<bool> onHoverChanged,
    required VoidCallback onDragStart,
    required VoidCallback onDragEnd,
    required ValueChanged<double> onDragUpdate,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (_) => onDragStart(),
        onPanEnd: (_) => onDragEnd(),
        onPanCancel: () => onDragEnd(),
        onPanUpdate: (details) => onDragUpdate(details.delta.dx),
        child: SizedBox(width: 10),
      ),
    );
  }

  List<Widget> _buildAdaptativeButtons(
    List<AdaptativeElement> elements,
    DesktopPosition position,
  ) {
    return elements
        .where((e) => e.desktopPosition == position)
        .map(
          (e) => IconButton(
            icon: Icon(e.icon),
            tooltip: e.tooltip,
            onPressed: e.onTap,
          ),
        )
        .toList();
  }

  Widget _buildMobileBody(BuildContext context) {
    final bottomPanelElements =
        widget.adaptativeElements
            ?.where((e) => e.mobilePosition == MobilePosition.bottomPanel)
            .toList() ??
        [];

    if (bottomPanelElements.isEmpty) return widget.body;

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    const collapsedHeight = 32.0;
    const expandedHeight = 80.0;
    final handleBar = Center(
      child: Container(
        width: 36,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    return SlidingUpPanel(
      minHeight: keyboardOpen ? 0 : collapsedHeight + bottomPadding,
      maxHeight: keyboardOpen ? 0 : expandedHeight + bottomPadding,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      color: Theme.of(context).cardColor,
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10.0,
          offset: Offset(0, -3),
        ),
      ],
      collapsed: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 14),
            handleBar,
          ],
        ),
      ),
      panel: Column(
        children: [
          SizedBox(
            height: collapsedHeight,
            child: Center(child: handleBar),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final e in bottomPanelElements)
                  IconButton(
                    icon: Icon(e.icon),
                    tooltip: e.tooltip,
                    onPressed: e.onTap,
                  ),
              ],
            ),
          ),
          SizedBox(height: bottomPadding),
        ],
      ),
      body: widget.body,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = widget.overrideIsDesktop ?? Device.isDesktop;

        final useDrawerLayout = !isDesktop || width < 800;

        final hasTopBar =
            widget.topBarContent != null ||
            (widget.adaptativeElements?.isNotEmpty ?? false) ||
            widget.leftPannel != null ||
            widget.rightPannel != null;

        Widget desktopTopBar = hasTopBar
            ? Builder(
                builder: (innerContext) => SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      if (widget.leftPannel != null)
                        IconButton(
                          icon: const Icon(Icons.menu_open),
                          onPressed: () {
                            if (useDrawerLayout) {
                              Scaffold.of(innerContext).openDrawer();
                            } else {
                              setState(() => _isLeftOpen = !_isLeftOpen);
                            }
                          },
                        ),
                      ..._buildAdaptativeButtons(
                        widget.adaptativeElements ?? [],
                        DesktopPosition.topBarLeft,
                      ),
                      if (widget.topBarContent != null)
                        Expanded(child: widget.topBarContent!)
                      else
                        const Spacer(),
                      ..._buildAdaptativeButtons(
                        widget.adaptativeElements ?? [],
                        DesktopPosition.topBarRight,
                      ),
                      if (widget.rightPannel != null)
                        IconButton(
                          icon: const Icon(Icons.menu_open),
                          onPressed: () {
                            if (useDrawerLayout) {
                              Scaffold.of(innerContext).openEndDrawer();
                            } else {
                              setState(() => _isRightOpen = !_isRightOpen);
                            }
                          },
                        ),
                    ],
                  ),
                ),
              )
            : const SizedBox();

        Widget activityBar = widget.activityActions != null
            ? isDesktop
                  ? Builder(
                      builder: (innerContext) => SizedBox(
                        width: 48,
                        child: CustomScrollView(
                          slivers: [
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  for (final action in widget.activityActions!)
                                    IconButton(
                                      icon: Icon(action.icon),
                                      tooltip: action.tooltip,
                                      onPressed: action.onTap,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Builder(
                      builder: (innerContext) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 4.0,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          spacing: 12.0,
                          runSpacing: 12.0,
                          children: [
                            for (final action in widget.activityActions!)
                              IconButton(
                                icon: Icon(action.icon),
                                tooltip: action.tooltip,
                                onPressed: action.onTap,
                              ),
                          ],
                        ),
                      ),
                    )
            : const SizedBox();

        PreferredSizeWidget mobileAppBar = AppBar(
          title: widget.topBarContent,
          leading: widget.leftPannel != null
              ? Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                )
              : null,
          actions: [
            ...?widget.adaptativeElements
                ?.where((e) => e.mobilePosition == MobilePosition.appBarRight)
                .map(
                  (e) => IconButton(
                    icon: Icon(e.icon),
                    tooltip: e.tooltip,
                    onPressed: e.onTap,
                  ),
                ),
            if ((widget.adaptativeElements?.any(
                      (e) => e.mobilePosition == MobilePosition.burger,
                    ) ??
                    false) ||
                widget.rightPannel != null)
              Builder(
                builder: (ctx) {
                  final hasBurgerItems = widget.adaptativeElements?.any(
                        (e) => e.mobilePosition == MobilePosition.burger,
                      ) ??
                      false;
                  return PopupMenuButton<void>(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (_) {
                      final items = <PopupMenuEntry<void>>[];
                      for (final e in widget.adaptativeElements?.where(
                            (e) => e.mobilePosition == MobilePosition.burger,
                          ) ??
                          <AdaptativeElement>[]) {
                        items.add(PopupMenuItem<void>(
                          onTap: e.onTap,
                          child: Row(
                            children: [
                              Icon(e.icon),
                              const SizedBox(width: 12),
                              Text(e.tooltip),
                            ],
                          ),
                        ));
                      }
                      if (widget.rightPannel != null) {
                        if (hasBurgerItems) items.add(const PopupMenuDivider());
                        items.add(PopupMenuItem<void>(
                          onTap: () => Scaffold.of(ctx).openEndDrawer(),
                          child: const Row(
                            children: [
                              Icon(Icons.menu_open),
                              SizedBox(width: 12),
                              Text('Open right panel'),
                            ],
                          ),
                        ));
                      }
                      return items;
                    },
                  );
                },
              ),
          ],
        );

        return Scaffold(
          appBar: !isDesktop ? mobileAppBar : null,
          drawer: useDrawerLayout && widget.leftPannel != null
              ? Drawer(
                  child: SafeArea(
                    child: Column(
                      children: [
                        Expanded(child: widget.leftPannel!),
                        if (widget.activityActions != null && !isDesktop)
                          activityBar,
                      ],
                    ),
                  ),
                )
              : null,
          endDrawer: useDrawerLayout && widget.rightPannel != null
              ? Drawer(child: SafeArea(child: widget.rightPannel!))
              : null,
          body: SafeArea(
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.activityActions != null) activityBar,
                      Expanded(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (widget.leftPannel != null &&
                                    !useDrawerLayout)
                                  AnimatedContainer(
                                    duration: _isDraggingLeft
                                        ? Duration.zero
                                        : const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    width: _isLeftOpen ? _leftWidth : 0,
                                    child: ClipRect(
                                      child: SizedBox(
                                        width: _leftWidth,
                                        child: widget.leftPannel!,
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      desktopTopBar,
                                      Expanded(child: widget.body),
                                    ],
                                  ),
                                ),
                                if (widget.rightPannel != null &&
                                    !useDrawerLayout)
                                  AnimatedContainer(
                                    duration: _isDraggingRight
                                        ? Duration.zero
                                        : const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    width: _isRightOpen ? _rightWidth : 0,
                                    child: ClipRect(
                                      child: SizedBox(
                                        width: _rightWidth,
                                        child: widget.rightPannel!,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (widget.leftPannel != null &&
                                _isLeftOpen &&
                                !useDrawerLayout)
                              Positioned(
                                left: _leftWidth - 5,
                                top: 0,
                                bottom: 0,
                                child: _buildResizeHandle(
                                  isHovering: _isHoveringLeft,
                                  isDragging: _isDraggingLeft,
                                  onHoverChanged: (value) =>
                                      setState(() => _isHoveringLeft = value),
                                  onDragStart: () {
                                    _rawLeftWidth = _leftWidth;
                                    setState(() => _isDraggingLeft = true);
                                  },
                                  onDragEnd: () =>
                                      setState(() => _isDraggingLeft = false),
                                  onDragUpdate: (dx) {
                                    _rawLeftWidth += dx;
                                    setState(
                                      () => _leftWidth = _rawLeftWidth.clamp(
                                        100.0,
                                        600.0,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            if (widget.rightPannel != null &&
                                _isRightOpen &&
                                !useDrawerLayout)
                              Positioned(
                                right: _rightWidth - 5,
                                top: 0,
                                bottom: 0,
                                child: _buildResizeHandle(
                                  isHovering: _isHoveringRight,
                                  isDragging: _isDraggingRight,
                                  onHoverChanged: (value) =>
                                      setState(() => _isHoveringRight = value),
                                  onDragStart: () {
                                    _rawRightWidth = _rightWidth;
                                    setState(() => _isDraggingRight = true);
                                  },
                                  onDragEnd: () =>
                                      setState(() => _isDraggingRight = false),
                                  onDragUpdate: (dx) {
                                    _rawRightWidth -= dx;
                                    setState(
                                      () => _rightWidth = _rawRightWidth.clamp(
                                        100.0,
                                        600.0,
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  )
                : _buildMobileBody(context),
          ),
        );
      },
    );
  }
}
