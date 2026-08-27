import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';

class HomeWidgetController extends BaseController {
  onAddPressed() {
    AppNavigator.back(result: true);
  }
}
