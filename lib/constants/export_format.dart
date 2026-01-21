import 'package:pdf/pdf.dart';

/// Supported logbook export formats by regulatory authority
enum LogbookExportFormat {
  international,
  easa,
  faa,
  ukCaa,
  dgac,
}

/// Metadata for each export format
class ExportFormatInfo {
  final String displayName;
  final String description;
  final PdfPageFormat pageFormat;
  final int rowsPerPage;
  final bool isTwoPageSpread;

  const ExportFormatInfo({
    required this.displayName,
    required this.description,
    required this.pageFormat,
    required this.rowsPerPage,
    this.isTwoPageSpread = false,
  });
}

/// Helper class for export format display and configuration
class ExportFormats {
  /// Get display name for a format
  static String getDisplayName(LogbookExportFormat format) {
    return getInfo(format).displayName;
  }

  /// Get description for a format
  static String getDescription(LogbookExportFormat format) {
    return getInfo(format).description;
  }

  /// Get full info for a format
  static ExportFormatInfo getInfo(LogbookExportFormat format) {
    switch (format) {
      case LogbookExportFormat.international:
        return const ExportFormatInfo(
          displayName: 'International',
          description: 'Universal balanced format',
          pageFormat: PdfPageFormat.a4,
          rowsPerPage: 20,
        );
      case LogbookExportFormat.easa:
        return const ExportFormatInfo(
          displayName: 'EASA',
          description: 'European standard, two-page spread',
          pageFormat: PdfPageFormat.a4,
          rowsPerPage: 16,
          isTwoPageSpread: true,
        );
      case LogbookExportFormat.faa:
        return const ExportFormatInfo(
          displayName: 'FAA',
          description: 'US Jeppesen Pro format',
          pageFormat: PdfPageFormat.letter,
          rowsPerPage: 27,
          isTwoPageSpread: true,
        );
      case LogbookExportFormat.ukCaa:
        return const ExportFormatInfo(
          displayName: 'UK CAA',
          description: 'UK commercial pilot format',
          pageFormat: PdfPageFormat.a4,
          rowsPerPage: 18,
          isTwoPageSpread: true,
        );
      case LogbookExportFormat.dgac:
        return const ExportFormatInfo(
          displayName: 'French DGAC',
          description: 'Bilingual French/English',
          pageFormat: PdfPageFormat.a5,
          rowsPerPage: 12,
        );
    }
  }

  /// Get all formats in display order
  static List<LogbookExportFormat> get allFormats => LogbookExportFormat.values;
}
