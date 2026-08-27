import 'package:b21pdf/core/events/app_event.dart';
import 'package:b21pdf/core/events/app_event_type.dart';
import 'package:b21pdf/core/events/app_event_bus.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:flutter_preview_file/flutter_preview_file.dart';
import 'package:get/get.dart';

class DeleteDocumentsController extends BaseController {
  final List<FileToolsFileInfo> files = List<FileToolsFileInfo>.from(
    (Get.arguments?['files'] as List?) ?? const [],
  );
  final Set<String> selectedPaths = <String>{};
  bool isSelected(FileToolsFileInfo file) => selectedPaths.contains(file.path);
  void onItemPressed(FileToolsFileInfo file) {
    final path = file.path;
    if (path == null) return;
    selectedPaths.contains(path)
        ? selectedPaths.remove(path)
        : selectedPaths.add(path);
    update();
  }

  void onSelectAllPressed() {
    if (selectedPaths.length == files.length) {
      selectedPaths.clear();
    } else {
      selectedPaths.addAll(files.map((file) => file.path).whereType<String>());
    }
    update();
  }

  Future<void> onDeletePressed() async {
    if (selectedPaths.isEmpty) return;
    for (final path in selectedPaths) {
      await FlutterPreviewFile.deleteFile(path);
    }
    AppEventBus.instance.publish(AppEvent(type: AppEventType.fileListRefresh));
    AppNavigator.back();
  }

  String resolveFileIcon(FileToolsFileInfo file) => switch (file.type) {
    FileToolsDocumentType.pdf => 'branding/pdf_logo',
    FileToolsDocumentType.excel => 'branding/excel_logo',
    _ => 'branding/word_logo',
  };
}
