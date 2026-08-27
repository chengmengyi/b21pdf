import 'package:b21pdf/core/permissions/presentation/permission_rationale_dialog.dart';
import 'package:b21pdf/core/lifecycle/app_lifecycle_service.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionResult {
  final bool isGranted;
  final bool isShowPermissionAd;
  const PermissionResult({
    required this.isGranted,
    required this.isShowPermissionAd,
  });
}

class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  Future<PermissionResult> requestPermission({
    required Permission permission,
  }) async {
    if (await permission.isGranted) {
      return const PermissionResult(isGranted: true, isShowPermissionAd: false);
    }
    final shouldRequest =
        await AppNavigator.showDialog<bool>(
          child: PermissionRationaleDialog(permission: permission),
        ) ??
        false;
    if (!shouldRequest) {
      return const PermissionResult(isGranted: false, isShowPermissionAd: true);
    }
    AppLifecycleService.instance.suppressNextForegroundAd();
    final status = await permission.request();
    return PermissionResult(
      isGranted: status.isGranted,
      isShowPermissionAd: true,
    );
  }
}
