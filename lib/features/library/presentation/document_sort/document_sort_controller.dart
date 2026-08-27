import 'package:b21pdf/core/analytics/analytics_event.dart';
import 'package:b21pdf/core/analytics/analytics_service.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';

enum SortType {
  dateNew(
    "Date(Newest First)",
    "document_library/sort_newest",
    "document_library/sort_newest_selected",
  ),
  dateOld(
    "Date(Oldest First)",
    "document_library/sort_oldest",
    "document_library/sort_oldest_selected",
  ),
  nameAZ(
    "Name(A-Z)",
    "document_library/sort_name_ascending",
    "document_library/sort_name_ascending_selected",
  ),
  nameZA(
    "Name(Z-A)",
    "document_library/sort_name_descending",
    "document_library/sort_name_descending_selected",
  );

  final String text;
  final String icon;
  final String iconVxe;
  const SortType(this.text, this.icon, this.iconVxe);
}

class DocumentSortController extends BaseController {
  final SortType selectedType;
  DocumentSortController({required this.selectedType});

  void onSortPressed(SortType type) {
    AnalyticsService.instance.trackEvent(
      pointType: AnalyticsEvent.fileSortChange,
      parameters: {"sort_type": type.name},
    );
    AppNavigator.back<SortType>(result: type);
  }
}
