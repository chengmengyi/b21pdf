import 'dart:async';
import 'dart:io';

import 'package:b21pdf/core/navigation/app_routes.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/overlay/overlay_service.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:flutter_preview_file/flutter_preview_file.dart';
import 'package:get/get.dart';

class PdfTaskProgressController extends BaseController {
  final List<String> imagePaths = List<String>.from(
    (Get.arguments?['imag'] as List?)?.whereType<String>() ?? const <String>[],
  );
  double progress = 0;
  bool generating = false;

  int get processedCount {
    if (imagePaths.isEmpty) return 0;
    return (progress * imagePaths.length).ceil().clamp(0, imagePaths.length);
  }

  int get progressPercent => (progress * 100).round();

  void onBackPressed() => AppNavigator.back();

  @override
  void onReady() {
    super.onReady();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    if (generating || imagePaths.isEmpty) return;
    generating = true;
    await OverlayService.instance.showProgressOverlay();
    try {
      final List<FileToolsFileInfo> images = <FileToolsFileInfo>[];
      for (final String path in imagePaths) {
        final File file = File(path);
        final FileStat stat = await file.stat();
        images.add(
          FileToolsFileInfo(
            name: path.split(Platform.pathSeparator).last,
            path: path,
            size: stat.size,
            updateTime: stat.modified.millisecondsSinceEpoch,
          ),
        );
      }
      final FileToolsFileInfo result =
          await FlutterPreviewFile.generatePdfFromImages(
            imageList: images,
            onProgress: (double value) {
              if (isClosed) return;
              progress = value.clamp(0, 1);
              unawaited(
                OverlayService.instance.updateProgressOverlay(
                  progress: progress,
                ),
              );
              update();
            },
          );
      if (isClosed) return;
      progress = 1;
      unawaited(
        OverlayService.instance.updateProgressOverlay(progress: progress),
      );
      update();
      AppNavigator.replaceNamed<void>(
        routeName: AppRoutes.processResultRoute,
        arguments: <String, dynamic>{'fileInfo': result},
      );
    } catch (error) {
      if (isClosed || error.toString().contains('generate_pdf_replaced')) {
        return;
      }
      rethrow;
    } finally {
      if (!isClosed) {
        generating = false;
      }
    }
  }
}
