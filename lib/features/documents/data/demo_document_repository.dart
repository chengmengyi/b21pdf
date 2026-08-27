import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_preview_file/flutter_preview_file.dart';
import 'package:path_provider/path_provider.dart';

class DemoDocumentRepository {
  DemoDocumentRepository._();

  static final DemoDocumentRepository instance = DemoDocumentRepository._();

  static const String _demoPdfAssetPath = 'assets/documents/sample_pdf.pdf';
  static const String _demoPdfFileName = 'PDF_Demo.pdf';
  static const String _demoDirectoryName = 'demo_documents';

  FileToolsFileInfo? _demoPdfInfo;

  Future<FileToolsFileInfo?> loadDemoDocument() async {
    final FileToolsFileInfo? cachedInfo = _demoPdfInfo;
    if (cachedInfo != null && File(cachedInfo.path ?? '').existsSync()) {
      return cachedInfo;
    }
    try {
      final File demoFile = await _ensureDemoPdf();
      final FileStat fileStat = await demoFile.stat();
      _demoPdfInfo = FileToolsFileInfo(
        name: _demoPdfFileName,
        type: FileToolsDocumentType.pdf,
        updateTime: fileStat.modified.millisecondsSinceEpoch,
        size: fileStat.size,
        path: demoFile.path,
      );
      return _demoPdfInfo;
    } catch (_) {
      return null;
    }
  }

  Future<File> _ensureDemoPdf() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final Directory demoDirectory = Directory(
      '${documentsDirectory.path}/$_demoDirectoryName',
    );
    if (!demoDirectory.existsSync()) {
      await demoDirectory.create(recursive: true);
    }
    final File demoFile = File('${demoDirectory.path}/$_demoPdfFileName');
    if (demoFile.existsSync()) {
      return demoFile;
    }
    final ByteData demoBytes = await rootBundle.load(_demoPdfAssetPath);
    await demoFile.writeAsBytes(demoBytes.buffer.asUint8List(), flush: true);
    return demoFile;
  }
}
