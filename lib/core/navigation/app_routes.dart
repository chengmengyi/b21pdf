import 'package:b21pdf/features/library/presentation/delete_documents/delete_documents_screen.dart';
import 'package:b21pdf/features/settings/language/presentation/language_selection_screen.dart';
import 'package:b21pdf/features/library/presentation/home/home_screen.dart';
import 'package:b21pdf/features/pdf_tools/presentation/image_selection/image_selection_screen.dart';
import 'package:b21pdf/features/startup/presentation/startup_screen.dart';
import 'package:b21pdf/features/notifications/presentation/permission/notification_permission_screen.dart';
import 'package:b21pdf/features/settings/overlay_permission/overlay_permission_screen.dart';
import 'package:b21pdf/features/viewers/pdf/presentation/pdf_viewer_screen.dart';
import 'package:b21pdf/features/viewers/word/presentation/word_viewer_screen.dart';
import 'package:b21pdf/features/viewers/excel/presentation/excel_viewer_screen.dart';
import 'package:b21pdf/features/pdf_tools/presentation/task_result/pdf_task_result_screen.dart';
import 'package:b21pdf/features/pdf_tools/presentation/task_progress/pdf_task_progress_screen.dart';
import 'package:b21pdf/features/settings/uninstall/uninstall_feedback_screen.dart';
import 'package:get/get.dart';

abstract final class AppRoutes {
  static const String launcherRoute = '/startup';
  static const String overlayPermissionRoute = '/open_overlay_access';
  static const String notificationRoute = '/open_notice';
  static const String homeRoute = '/dashboard';
  static const String deleteFileRoute = '/remove_document';
  static const String chooseLanguageRoute = '/select_locale';
  static const String previewPdfRoute = '/viewer_pdf';
  static const String previewWordRoute = '/viewer_word';
  static const String previewExcelRoute = '/viewer_excel';
  static const String uninstallRoute = '/uninstall';
  static const String imagesResultRoute = '/pictures_output';
  static const String processWaitingRoute = '/task_progress';
  static const String processResultRoute = '/task_output';

  static final List<GetPage<dynamic>> pages = [
    GetPage(name: launcherRoute, page: StartupScreen.new),
    GetPage(name: overlayPermissionRoute, page: OverlayPermissionScreen.new),
    GetPage(name: notificationRoute, page: NotificationPermissionScreen.new),
    GetPage(name: homeRoute, page: HomeScreen.new),
    GetPage(name: deleteFileRoute, page: DeleteDocumentsScreen.new),
    GetPage(name: chooseLanguageRoute, page: LanguageSelectionScreen.new),
    GetPage(name: previewPdfRoute, page: PdfViewerScreen.new),
    GetPage(name: previewWordRoute, page: WordViewerScreen.new),
    GetPage(name: previewExcelRoute, page: ExcelViewerScreen.new),
    GetPage(name: uninstallRoute, page: UninstallFeedbackScreen.new),
    GetPage(name: imagesResultRoute, page: ImageSelectionScreen.new),
    GetPage(name: processWaitingRoute, page: PdfTaskProgressScreen.new),
    GetPage(name: processResultRoute, page: PdfTaskResultScreen.new),
  ];
}
