import 'package:flutter/material.dart';
import 'package:mycelium/utils/device.dart';

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

enum DesktopPosition { topBarLeft, topBarRight }

enum MobilePosition { burger, appBarLeft, appBarRight, }

class Element {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final 

  ActivityAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
}

class AdaptativeScaffold extends StatefulWidget {
  final Widget body;
  final Widget? leftPannel;
  final Widget? rightPannel;

  final List<ActivityAction>? activityActions; // for "activity bar"
  final Widget? desktopTopBar;
  final PreferredSizeWidget? mobileAppBar;

  final bool? overrideIsDesktop; // for testing

  const AdaptativeScaffold({
    super.key,
    required this.body,
    this.leftPannel,
    this.rightPannel,
    this.activityActions,
    this.desktopTopBar,
    this.mobileAppBar,
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
    if (widget.desktopTopBar == null) {
      _isLeftOpen = true;
      _isRightOpen = true;
    }
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = widget.overrideIsDesktop ?? Device.isDesktop;

        final useDrawerLayout = !isDesktop || width < 800;

        Widget desktopTopBar = widget.desktopTopBar != null
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
                      Expanded(child: widget.desktopTopBar!),
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

        // Et les boutons qui sont norlame,et dans la topbar sur pc sur mobile ils seront dans un menu en bas de la zone d'edit ou bien dans la appbar en haut dans un bouton menu burger, à la obsidian. Et juste à côté menu brurger y'aur juste le bouton + pour importer et le bouton apprendre, le reste sera dans menu burger. Et bouto nd'ouverture de left pannel en haut à gauche mais pas pour drawer de droite.
        // Dans bouton du bas on aura gauche droite, pq pas rechercher. QUoique pas fou car y'aura en plus la barre de révision en bas. Peut etre juste barre de modif en bas quand on clique comme sur obsidian, mis optionnel (egenre avec undo/redo et pq pas des boutons de wysiwyg), et sinon par défaut rien à part le bouton dismiss pour les fragment ? quoique on faudra que ce bouton dismiss soit à côté du bouton next fragment, pareil sur pc, et sinon dans le burger sur mobile/top bar pc. Mais quid de cs boutons de nav..?

        return Scaffold(
          appBar: !isDesktop ? widget.mobileAppBar : null,
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
                                      if (widget.desktopTopBar != null)
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
                : widget.body,
          ),
        );
      },
    );
  }
}
