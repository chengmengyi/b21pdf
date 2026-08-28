import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:b21pdf/core/ads/ad_service.dart';
import 'package:b21pdf/core/ads/ad_scene.dart';
import 'package:b21pdf/core/ads/ad_placement.dart';
import 'package:b21pdf/core/user/user_eligibility_service.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/analytics/analytics_event.dart';
import 'package:b21pdf/core/analytics/analytics_service.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_preview_file/flutter_preview_file.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

enum PdfEditType {
  highlight('editor/highlight_tool',"editor/highlight_tool_sel"),
  underline('editor/underline_tool',"editor/underline_tool_sel"),
  strikeThrough('editor/strikethrough_tool',"editor/strikethrough_tool_sel"),
  pen('editor/freehand_tool',"editor/freehand_tool_sel");

  final String iconUns;
  final String iconSel;
  const PdfEditType(this.iconUns,this.iconSel);
}

class PdfStroke {
  final int pageNumber;
  final List<Offset> points;
  final Color color;
  final double width;
  const PdfStroke({
    required this.pageNumber,
    required this.points,
    required this.color,
    required this.width,
  });
}

class PdfViewerScreenController extends BaseController {
  final FileToolsFileInfo fileInfo = Get.arguments['file'] as FileToolsFileInfo;
  final GlobalKey<SfPdfViewerState> viewerKey = GlobalKey<SfPdfViewerState>();
  final PdfViewerController viewerController = PdfViewerController();
  final UndoHistoryController undoController = UndoHistoryController();
  final Map<int, Uint8List?> thumbnails = <int, Uint8List?>{};
  final Map<int, Size> pageSizes = <int, Size>{};
  final List<PdfStroke> penStrokes = <PdfStroke>[];
  final List<PdfStroke> redoStrokes = <PdfStroke>[];
  List<Offset> draftPoints = <Offset>[];
  PdfEditType? selectedType;
  bool canLoadViewer = false;
  bool documentLoaded = false;
  bool saving = false;
  bool penPanelVisible = false;
  bool hasTextSelection = false;
  bool isExiting = false;
  DateTime? selectionDismissedAt;
  int pageCount = 0;
  int currentPage = 1;
  Color penColor = const Color(0xff067BF2);
  double penWidth = 8;
  Timer? penPanelTimer;
  final List<Color> penColors = const [
    Color(0xffF4411F),
    Color(0xff1A1D22),
    Color(0xff067BF2),
    Color(0xff23A55A),
    Color(0xffF4C542),
  ];

  String get fileName {
    if ((fileInfo.name ?? '').isNotEmpty) {
      return fileInfo.name!;
    }
    return (fileInfo.path ?? '').split(Platform.pathSeparator).last;
  }

  bool get penMode => selectedType == PdfEditType.pen;

  @override
  void onInit() {
    super.onInit();
    undoController.addListener(_onViewerStateChanged);
  }

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      canLoadViewer = true;
      update();
    });
  }

  void _onViewerStateChanged() => update();
  void onDocumentLoaded(PdfDocumentLoadedDetails details) {
    documentLoaded = true;
    pageCount = details.document.pages.count;
    pageSizes.clear();
    for (var index = 0; index < pageCount; index++) {
      pageSizes[index + 1] = details.document.pages[index].size;
    }
    update();
    _loadThumbnails();
  }

  void onPageChanged(PdfPageChangedDetails details) {
    currentPage = details.newPageNumber;
    update();
  }

  void onTextSelectionChanged(PdfTextSelectionChangedDetails details) {
    final hasSelection = details.selectedText?.isNotEmpty == true;
    if (hasTextSelection && !hasSelection) {
      selectionDismissedAt = DateTime.now();
    }
    hasTextSelection = hasSelection;
  }

  void onAnnotationToolSelected(PdfEditType type) {
    if (type == PdfEditType.pen) {
      onPenPressed();
      return;
    }
    hidePenSettings();
    draftPoints = <Offset>[];
    final selectedLines =
        viewerKey.currentState?.getSelectedTextLines() ?? <PdfTextLine>[];
    selectedType = type;
    viewerController.annotationMode = PdfAnnotationMode.none;
    if (selectedLines.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select text first'.tr);
      update();
      return;
    }
    final Annotation annotation = switch (type) {
      PdfEditType.highlight => HighlightAnnotation(
        textBoundsCollection: selectedLines,
      ),
      PdfEditType.underline => UnderlineAnnotation(
        textBoundsCollection: selectedLines,
      ),
      PdfEditType.strikeThrough => StrikethroughAnnotation(
        textBoundsCollection: selectedLines,
      ),
      _ => throw StateError('Unsupported text annotation type'),
    };
    viewerController.addAnnotation(annotation);
    update();
  }

  void onPenPressed() {
    if (!documentLoaded || saving) return;
    final enablePen = !penMode;
    selectedType = enablePen ? PdfEditType.pen : null;
    draftPoints = <Offset>[];
    viewerController.annotationMode = PdfAnnotationMode.none;
    viewerController.clearSelection();
    if (enablePen) {
      showPenSettings();
    } else {
      hidePenSettings();
    }
    update();
  }

  void showPenSettings() {
    penPanelTimer?.cancel();
    penPanelVisible = true;
    update();
    penPanelTimer = Timer(const Duration(seconds: 3), () {
      penPanelVisible = false;
      update();
    });
  }

  void hidePenSettings() {
    penPanelTimer?.cancel();
    penPanelTimer = null;
    penPanelVisible = false;
  }

  void selectPenColor(Color color) {
    penColor = color;
    showPenSettings();
  }

  void selectPenWidth(double width) {
    penWidth = width;
    showPenSettings();
  }

  void navigateToPage(int pageNumber) {
    viewerController.jumpToPage(pageNumber);
    currentPage = pageNumber;
    update();
  }

  void beginPenStroke(Offset point) {
    if (!penMode || saving) return;
    draftPoints = <Offset>[point];
    update();
  }

  void extendPenStroke(Offset point) {
    if (draftPoints.isEmpty || !penMode) return;
    draftPoints.add(point);
    update();
  }

  void finishPenStroke() {
    if (draftPoints.isEmpty) return;
    penStrokes.add(
      PdfStroke(
        pageNumber: currentPage,
        points: List<Offset>.from(draftPoints),
        color: penColor,
        width: penWidth,
      ),
    );
    redoStrokes.clear();
    draftPoints = <Offset>[];
    update();
  }

  void onUndoPressed() {
    if (penStrokes.isNotEmpty) {
      redoStrokes.add(penStrokes.removeLast());
    } else {
      undoController.undo();
    }
    update();
  }

  void onRedoPressed() {
    if (redoStrokes.isNotEmpty) {
      penStrokes.add(redoStrokes.removeLast());
    } else {
      undoController.redo();
    }
    update();
  }

  Future<void> onSavePressed() async {
    if (!documentLoaded || saving) return;
    saving = true;
    update();
    try {
      AnalyticsService.instance.trackEvent(
        pointType: AnalyticsEvent.editor_save_click,
      );
      List<int> bytes = await viewerController.saveDocument();
      if (penStrokes.isNotEmpty) {
        final document = PdfDocument(inputBytes: bytes);
        for (final stroke in penStrokes) {
          if (stroke.pageNumber > document.pages.count) {
            continue;
          }
          final dynamic page = document.pages[stroke.pageNumber - 1];
          final Size size = page.size as Size;
          final path = PdfPath();
          for (var index = 1; index < stroke.points.length; index++) {
            final from = stroke.points[index - 1];
            final to = stroke.points[index];
            path.addLine(
              Offset(from.dx * size.width, from.dy * size.height),
              Offset(to.dx * size.width, to.dy * size.height),
            );
          }
          page.graphics.drawPath(
            path,
            pen: PdfPen(
              PdfColor(
                (stroke.color.r * 255).round(),
                (stroke.color.g * 255).round(),
                (stroke.color.b * 255).round(),
              ),
              width: (stroke.width / 800) * size.width,
            ),
          );
        }
        bytes = await document.save();
        document.dispose();
      }
      await File(fileInfo.path!).writeAsBytes(bytes, flush: true);
      penStrokes.clear();
      redoStrokes.clear();
      Fluttertoast.showToast(msg: 'Saved successfully'.tr);
    } catch (error) {
      Fluttertoast.showToast(msg: '$error');
    } finally {
      saving = false;
      update();
    }
  }

  Future<void> _loadThumbnails() async {
    for (var page = 1; page <= pageCount; page++) {
      try {
        thumbnails[page] = await FlutterPreviewFile.renderPdfPageToImageBytes(
          pdfPath: fileInfo.path!,
          pageIndex: page - 1,
          width: 160,
        );
        update();
      } catch (_) {
        thumbnails[page] = null;
      }
    }
  }

  Future<bool> onSystemBackRequested() async {
    if (isExiting) return true;
    if (hasTextSelection) {
      viewerController.clearSelection();
      return false;
    }
    final dismissedAt = selectionDismissedAt;
    if (dismissedAt != null &&
        DateTime.now().difference(dismissedAt) <
            const Duration(milliseconds: 500)) {
      return false;
    }
    isExiting = true;
    _showExitAdIfEligible();
    return true;
  }

  void onBackPressed() {
    if (isExiting) return;
    isExiting = true;
    AppNavigator.back();
    _showExitAdIfEligible();
  }

  void _showExitAdIfEligible() {
    if (UserEligibilityService.instance.isEligibleUser) {
      AdService.instance.showCachedAd(
        adScene: AdScene.pr_exit,
        adPosId: AdPlacement.pr_readback,
      );
    }
  }

  @override
  void onClose() {
    penPanelTimer?.cancel();
    undoController.removeListener(_onViewerStateChanged);
    undoController.dispose();
    viewerController.dispose();
    super.onClose();
  }
}
