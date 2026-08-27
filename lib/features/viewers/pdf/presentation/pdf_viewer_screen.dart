import 'dart:typed_data';

import 'package:b21pdf/features/viewers/pdf/presentation/pdf_viewer_controller.dart';
import 'package:b21pdf/core/presentation/base_screen.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_preview_file/flutter_preview_file.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PdfViewerScreen extends BaseScreen<PdfViewerScreenController> {
  const PdfViewerScreen({super.key});
  @override
  PdfViewerScreenController createController() => PdfViewerScreenController();

  @override
  Color get navigationBarColor => Colors.white;

  @override
  Future<bool> canPopRoute(PdfViewerScreenController controller) =>
      controller.onSystemBackRequested();

  @override
  Widget buildContent(
    BuildContext context,
    PdfViewerScreenController controller,
  ) => GetBuilder<PdfViewerScreenController>(
    init: controller,
    global: false,
    builder: (controller) => Column(
      children: [
        _buildTitleBar(controller),
        _buildMainContent(controller),
        _buildBottomBar(controller),
      ],
    ),
  );

  Widget _buildMainContent(PdfViewerScreenController controller) => Expanded(
    child: Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(left: 8.w, right: 8.w, top: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 5,
            offset: const Offset(0, -0.5),
          ),
        ],
      ),
      child: !controller.canLoadViewer
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: controller.penMode
                    ? (details) => controller.beginPenStroke(
                        _normalize(details.localPosition, constraints.biggest),
                      )
                    : null,
                onPanUpdate: controller.penMode
                    ? (details) => controller.extendPenStroke(
                        _normalize(details.localPosition, constraints.biggest),
                      )
                    : null,
                onPanEnd: controller.penMode
                    ? (_) => controller.finishPenStroke()
                    : null,
                child: Stack(
                  children: [
                    PdfFileView(
                      filePath: controller.fileInfo.path ?? '',
                      viewerKey: controller.viewerKey,
                      controller: controller.viewerController,
                      undoController: controller.undoController,
                      pageLayoutMode: PdfPageLayoutMode.single,
                      onDocumentLoaded: controller.onDocumentLoaded,
                      onPageChanged: controller.onPageChanged,
                      onTextSelectionChanged: controller.onTextSelectionChanged,
                      loadingBuilder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                      messageBuilder: (_, message) => Center(
                        child: LocalizedTextView('Preview unavailable'.tr),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _PdfPenPainter(
                            strokes: controller.penStrokes
                                .where(
                                  (stroke) =>
                                      stroke.pageNumber ==
                                      controller.currentPage,
                                )
                                .toList(),
                            draft: controller.draftPoints,
                            draftColor: controller.penColor,
                            draftWidth: controller.penWidth,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _penPanel(controller),
                    ),
                  ],
                ),
              ),
            ),
    ),
  );

  Offset _normalize(Offset point, Size size) => Offset(
    (point.dx / size.width).clamp(0, 1),
    (point.dy / size.height).clamp(0, 1),
  );

  Widget _buildBottomBar(PdfViewerScreenController controller) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12.w),
        topRight: Radius.circular(12.w),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 5,
          offset: const Offset(0, -0.5),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8.h),
        SizedBox(
          height: 88.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: controller.pageCount,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) {
              final page = index + 1;
              final Uint8List? bytes = controller.thumbnails[page];
              return TapGuardView(
                onPressed: () => controller.navigateToPage(page),
                child: Container(
                  width: 72.w,
                  decoration: BoxDecoration(
                    color: const Color(0xffF3F5F7),
                    borderRadius: BorderRadius.circular(3.w),
                    border: Border.all(
                      width: page == controller.currentPage ? 2.w : 0.5.w,
                      color: page == controller.currentPage
                          ? const Color(0xff067BF2)
                          : const Color(0xffEBEBEB),
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (bytes != null)
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Image.memory(bytes, fit: BoxFit.contain),
                          ),
                        ),
                      Positioned(
                        right: 2.w,
                        bottom: 2.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 1.h,
                          ),
                          color: Colors.black54,
                          child: Text(
                            '$page',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => SizedBox(width: 8.w),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 44.h,
          child: Row(
            children: PdfEditType.values.map((type) {
              final selected = type == controller.selectedType;
              return Expanded(
                child: TapGuardView(
                  onPressed: () => controller.onAnnotationToolSelected(type),
                  child: Center(
                    child: Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.w),
                        border: selected
                            ? Border.all(width: 1.w, color: Color(0xffD12629))
                            : null,
                      ),
                      child: AssetPictureView(
                        type.icon,
                        width: 38.w,
                        height: 38.w,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            SizedBox(width: 16.w),
            TapGuardView(
              onPressed: controller.onUndoPressed,
              child: AssetPictureView('editor/undo', width: 30.w, height: 30.w),
            ),
            SizedBox(width: 10.w),
            TapGuardView(
              onPressed: controller.onRedoPressed,
              child: AssetPictureView('editor/redo', width: 30.w, height: 30.w),
            ),
            const Spacer(),
            TapGuardView(
              onPressed: controller.onSavePressed,
              child: Container(
                padding: EdgeInsets.only(
                  left: 34.w,
                  right: 34.w,
                  top: 6.h,
                  bottom: 6.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffD12629),
                  borderRadius: BorderRadius.circular(22.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AssetPictureView("editor/save", width: 25.w, height: 25.w),
                    SizedBox(width: 4.w),
                    LocalizedTextView(
                      controller.saving ? 'Saving...'.tr : 'Save'.tr,
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16.w),
          ],
        ),
        SizedBox(height: 8.h),
      ],
    ),
  );

  Widget _buildTitleBar(PdfViewerScreenController controller) => Container(
    width: double.infinity,
    color: Colors.white,
    child: SafeArea(
      top: true,
      bottom: false,
      child: SizedBox(
        height: 44.h,
        child: Stack(
          children: [
            TapGuardView(
              onPressed: controller.onBackPressed,
              child: SizedBox(
                width: 44.w,
                height: 44.h,
                child: Center(
                  child: AssetPictureView(
                    'navigation/back',
                    width: 33.w,
                    height: 33.w,
                  ),
                ),
              ),
            ),
            Align(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 52.w),
                child: LocalizedTextView(
                  controller.fileName,
                  fontSize: 18.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _penPanel(PdfViewerScreenController controller) => IgnorePointer(
    ignoring: !controller.penPanelVisible,
    child: AnimatedOpacity(
      duration: const Duration(milliseconds: 260),
      opacity: controller.penPanelVisible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 260),
        offset: controller.penPanelVisible
            ? Offset.zero
            : const Offset(0, 0.12),
        child: Container(
          margin: EdgeInsets.fromLTRB(8.w, 0, 8.w, 8.h),
          padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.w),
            border: Border.all(color: const Color(0xffE7EAEB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18.w,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  LocalizedTextView(
                    'Color'.tr,
                    fontSize: 12.sp,
                    color: const Color(0xff1A1D22),
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: controller.penColors
                          .map(
                            (color) => TapGuardView(
                              onPressed: () => controller.selectPenColor(color),
                              child: Container(
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: color == controller.penColor
                                        ? 3.w
                                        : 1.w,
                                    color: color == controller.penColor
                                        ? const Color(0xff1A1D22)
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  LocalizedTextView(
                    'Width'.tr,
                    fontSize: 12.sp,
                    color: const Color(0xff1A1D22),
                    fontWeight: FontWeight.bold,
                  ),
                  Expanded(
                    child: Slider(
                      value: controller.penWidth,
                      min: 2,
                      max: 30,
                      activeColor: controller.penColor,
                      onChanged: controller.selectPenWidth,
                    ),
                  ),
                  SizedBox(
                    width: 26.w,
                    child: LocalizedTextView(
                      controller.penWidth.toStringAsFixed(0),
                      fontSize: 12.sp,
                      color: const Color(0xff858C92),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PdfPenPainter extends CustomPainter {
  final List<PdfStroke> strokes;
  final List<Offset> draft;
  final Color draftColor;
  final double draftWidth;
  const _PdfPenPainter({
    required this.strokes,
    required this.draft,
    required this.draftColor,
    required this.draftWidth,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final strokeEntries = <({List<Offset> points, Color color, double width})>[
      ...strokes.map(
        (item) => (points: item.points, color: item.color, width: item.width),
      ),
      (points: draft, color: draftColor, width: draftWidth),
    ];
    for (final entry in strokeEntries) {
      final stroke = entry.points;
      if (stroke.length < 2) continue;
      final paint = Paint()
        ..color = entry.color
        ..strokeWidth = entry.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(stroke.first.dx * size.width, stroke.first.dy * size.height);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx * size.width, point.dy * size.height);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PdfPenPainter oldDelegate) => true;
}
