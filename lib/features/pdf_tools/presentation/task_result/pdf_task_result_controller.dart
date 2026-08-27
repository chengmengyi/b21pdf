import 'dart:io';

import 'package:b21pdf/core/navigation/app_routes.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:flutter_preview_file/flutter_preview_file.dart';
import 'package:get/get.dart';

class PdfTaskResultController extends BaseController {
  final FileToolsFileInfo fileInfo =
      Get.arguments['fileInfo'] as FileToolsFileInfo;

  String get fileName {
    final String name = fileInfo.name ?? '';
    if (name.isNotEmpty) return name;
    return (fileInfo.path ?? '').split(Platform.pathSeparator).last;
  }

  String get fileDetail {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(
      fileInfo.updateTime ?? DateTime.now().millisecondsSinceEpoch,
    );
    final String dateText =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final double size = (fileInfo.size ?? 0) / 1024 / 1024;
    return '$dateText | ${size.toStringAsFixed(1)}M';
  }

  void onBackPressed() => AppNavigator.backWithExitAd<void>();

  void onOpenPressed() {
    AppNavigator.replaceNamed<void>(
      routeName: AppRoutes.previewPdfRoute,
      arguments: <String, dynamic>{'file': fileInfo},
    );
  }
}
