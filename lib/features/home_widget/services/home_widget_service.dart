import 'package:b21pdf/features/home_widget/presentation/home_widget_bottom_sheet.dart';
import 'package:b21pdf/core/events/app_event.dart';
import 'package:b21pdf/core/events/app_event_type.dart';
import 'package:b21pdf/core/events/app_event_bus.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/storage/preferences/insert_widget_cache.dart';
import 'package:flutter_add_widget_plugins/flutter_add_widget_plugins.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

enum InsertWidgetType {
  home("Home", "home_widget/home_tool"),
  merge("Merge", "home_widget/merge_tool"),
  import("Import", "home_widget/import_tool"),
  convert("Convert", "home_widget/convert_tool");

  final String text;
  final String icon;
  const InsertWidgetType(this.text, this.icon);
}

class HomeWidgetService {
  HomeWidgetService._();

  static final HomeWidgetService instance = HomeWidgetService._();

  final List<WidgetInfo> _widgetInfoList = <WidgetInfo>[];

  Future<void> openWidgetPicker() async {
    var result = await AppNavigator.showBottomSheet<bool>(
      child: const HomeWidgetBottomSheet(),
    );
    if (result == true) {
      await _addSelectedWidget();
    }
  }

  Future<void> _addSelectedWidget() async {
    _initializeWidgetMetadata();
    await FlutterAddWidgetPlugins.instance.addWidget(
      items: _widgetInfoList,
      layoutName: "insert_widget_layout",
      searchText: "Search".tr,
    );
    await InsertWidgetCache.saveAdded(true);
    AppEventBus.instance.publish(AppEvent(type: AppEventType.widgetAdded));
  }

  void _initializeWidgetMetadata() {
    _widgetInfoList.clear();
    for (var value in InsertWidgetType.values) {
      _widgetInfoList.add(
        WidgetInfo(icon: value.icon, name: value.text.tr, type: value.name),
      );
    }
  }
}
