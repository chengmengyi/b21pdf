import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TabView extends StatelessWidget {
  const TabView({
    super.key,
    this.tabController,
    this.selectedIndex = 0,
    this.onTap,
    this.selectedColor = const Color(0xFF202326),
    this.unselectedColor = const Color(0xFF6E7FA5),
    this.labelStyle,
    this.unselectedLabelStyle,
  });

  final TabController? tabController;
  final int selectedIndex;
  final ValueChanged<int>? onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;

  static const List<String> tabTextList = <String>[
    'All',
    'PDF',
    'Word',
    'Excel',
  ];

  @override
  Widget build(BuildContext context) {
    final ExtendedTabBar tabBar = ExtendedTabBar(
      controller: tabController,
      onTap: onTap,
      isScrollable: true,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: _FixedWidthIndicator(
        indicatorWidth: 16.w,
        indicatorHeight: 2,
        indicatorColor: const Color(0xFF242C3C),
      ),
      labelPadding: EdgeInsets.zero,
      dividerColor: Colors.transparent,
      labelColor: selectedColor,
      unselectedLabelColor: unselectedColor,
      labelStyle:
          labelStyle ??
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      unselectedLabelStyle:
          unselectedLabelStyle ??
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      tabs: tabTextList
          .map(
            (String tabText) => Tab(
              child: SizedBox(
                width: 68.w,
                child: Center(child: Text(tabText.tr)),
              ),
            ),
          )
          .toList(),
    );

    if (tabController != null) {
      return tabBar;
    }
    final int safeSelectedIndex = selectedIndex.clamp(
      0,
      tabTextList.length - 1,
    );
    return DefaultTabController(
      key: ValueKey<int>(safeSelectedIndex),
      length: tabTextList.length,
      initialIndex: safeSelectedIndex,
      child: tabBar,
    );
  }
}

class _FixedWidthIndicator extends Decoration {
  const _FixedWidthIndicator({
    required this.indicatorWidth,
    required this.indicatorHeight,
    required this.indicatorColor,
  });

  final double indicatorWidth;
  final double indicatorHeight;
  final Color indicatorColor;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _FixedWidthIndicatorPainter(this);
  }
}

class _FixedWidthIndicatorPainter extends BoxPainter {
  _FixedWidthIndicatorPainter(this.decoration);

  final _FixedWidthIndicator decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Size? size = configuration.size;
    if (size == null) {
      return;
    }
    final Paint paint = Paint()
      ..color = decoration.indicatorColor
      ..style = PaintingStyle.fill;
    final double left =
        offset.dx + (size.width - decoration.indicatorWidth) / 2;
    final double top = offset.dy + size.height - decoration.indicatorHeight;
    final RRect indicatorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        left,
        top,
        decoration.indicatorWidth,
        decoration.indicatorHeight,
      ),
      Radius.circular(decoration.indicatorHeight / 2),
    );
    canvas.drawRRect(indicatorRect, paint);
  }
}
