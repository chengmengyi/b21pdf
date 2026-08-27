import 'package:b21pdf/core/storage/preference_keys.dart';

class DocumentSortCache {
  DocumentSortCache._();
  static String readSortName(String tabName) =>
      getStorage.read<String>('document_sort_${tabName}_vza') ?? 'dateNew';
  static Future<void> writeSortName({
    required String tabName,
    required String sortName,
  }) => getStorage.write('document_sort_${tabName}_vza', sortName);
}
