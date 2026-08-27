import 'package:b21pdf/core/permissions/permission_service.dart';
import 'package:b21pdf/core/navigation/app_routes.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/analytics/analytics_event.dart';
import 'package:b21pdf/core/analytics/analytics_service.dart';
import 'package:b21pdf/features/pdf_tools/presentation/image_selection/image_selection_controller.dart';
import 'package:doc_scan_flutter/doc_scan.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

final class ImageImportService {
  ImageImportService._();

  static final ImageImportService instance = ImageImportService._();

  Future<List<String>> scanDocuments({bool openResult = true}) async {
    if (openResult) {
      AnalyticsService.instance.trackEvent(pointType: AnalyticsEvent.tool_scan);
    }
    if (!await Permission.camera.isGranted) {
      final PermissionResult permissionResult = await PermissionService.instance
          .requestPermission(permission: Permission.camera);
      if (!permissionResult.isGranted) {
        return const <String>[];
      }
    }

    final List<String>? scanPathList = await DocumentScanner.scan(
      format: DocScanFormat.jpeg,
    );
    final List<String> paths = _filterValidImagePaths(scanPathList);
    if (openResult) {
      _openImageSelection(paths, ImageInputSource.scan);
    }
    return paths;
  }

  Future<List<String>> pickImages({bool openResult = true}) async {
    if (openResult) {
      AnalyticsService.instance.trackEvent(
        pointType: AnalyticsEvent.tool_image_to_pdf,
      );
    }
    final List<XFile> imageList = await ImagePicker().pickMultiImage();
    final List<String> paths = _filterValidImagePaths(
      imageList.map((XFile image) => image.path),
    );
    if (openResult) {
      _openImageSelection(paths, ImageInputSource.choose);
    }
    return paths;
  }

  List<String> _filterValidImagePaths(Iterable<String>? imagePaths) {
    return imagePaths
            ?.where((String path) => path.isNotEmpty)
            .toList(growable: false) ??
        const <String>[];
  }

  void _openImageSelection(List<String> validPaths, ImageInputSource source) {
    if (validPaths.isEmpty) return;

    AppNavigator.pushNamed<void>(
      routeName: AppRoutes.imagesResultRoute,
      arguments: <String, dynamic>{'imag': validPaths, 'source': source},
    );
  }
}
