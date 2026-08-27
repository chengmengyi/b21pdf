import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class PermissionRationaleController extends BaseController {
  final Permission permission;
  PermissionRationaleController({required this.permission});

  String buildPermissionMessage() {
    if (permission == Permission.storage ||
        permission == Permission.manageExternalStorage) {
      return 'Please allow storage access to continue.'.tr;
    }
    if (permission == Permission.camera) {
      return 'Please allow camera access to continue.'.tr;
    }
    return 'Please allow access to continue.'.tr;
  }

  void onAllowPressed() => AppNavigator.back<bool>(result: true);

  void onLaterPressed() {
    AppNavigator.back<bool>(result: false);
  }
}
