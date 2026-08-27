import 'dart:io';

import 'package:b21pdf/features/pdf_tools/services/image_import_service.dart';
import 'package:b21pdf/core/permissions/permission_service.dart';
import 'package:b21pdf/core/navigation/app_routes.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

enum ImageInputSource { scan, choose }

class ImageSelectionController extends BaseController {
  final List<String> imagePaths = List<String>.from(
    (Get.arguments?['imag'] as List?)?.whereType<String>() ?? const <String>[],
  );
  final ImageInputSource source =
      Get.arguments?['source'] as ImageInputSource? ?? ImageInputSource.choose;
  final PageController pageController = PageController();
  final ScrollController thumbnailController = ScrollController();
  int selectedIndex = 0;

  void onBackPressed() => AppNavigator.backWithExitAd<void>();

  void selectImage(int index) {
    if (index < 0 || index >= imagePaths.length) {
      return;
    }
    selectedIndex = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
    );
    _scrollThumbnail();
    update();
  }

  void onPageChanged(int index) {
    selectedIndex = index;
    _scrollThumbnail();
    update();
  }

  Future<void> onReplacePressed() async {
    final List<String> newPaths = await _pickImages();
    if (newPaths.isEmpty || imagePaths.isEmpty) return;
    imagePaths[selectedIndex] = newPaths.first;
    update();
  }

  Future<void> onAddPressed() async {
    final List<String> newPaths = await _pickImages();
    if (newPaths.isEmpty) return;
    imagePaths.addAll(newPaths);
    update();
  }

  Future<List<String>> _pickImages() {
    return switch (source) {
      ImageInputSource.scan => ImageImportService.instance.scanDocuments(
        openResult: false,
      ),
      ImageInputSource.choose => ImageImportService.instance.pickImages(
        openResult: false,
      ),
    };
  }

  Future<void> onSavePressed() async {
    if (imagePaths.isEmpty) return;
    if (imagePaths.length > 100) {
      Fluttertoast.showToast(msg: 'Max 100 images allowed'.tr);
      return;
    }
    final Permission permission = await _resolveRequiredStoragePermission();
    final PermissionResult result = await PermissionService.instance
        .requestPermission(permission: permission);
    if (!result.isGranted) return;
    AppNavigator.pushNamed<void>(
      routeName: AppRoutes.processWaitingRoute,
      arguments: <String, dynamic>{
        'imag': List<String>.from(imagePaths),
        'source': source,
      },
    );
  }

  Future<Permission> _resolveRequiredStoragePermission() async {
    if (!Platform.isAndroid) return Permission.storage;
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 30
        ? Permission.manageExternalStorage
        : Permission.storage;
  }

  void _scrollThumbnail() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!thumbnailController.hasClients) return;
      final double target = (selectedIndex * 80.0).clamp(
        0,
        thumbnailController.position.maxScrollExtent,
      );
      thumbnailController.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    thumbnailController.dispose();
    super.onClose();
  }
}
