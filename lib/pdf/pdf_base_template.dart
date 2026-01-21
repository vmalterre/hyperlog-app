import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../constants/export_format.dart';
import '../models/logbook_entry.dart';
import 'pdf_utils.dart';

/// Abstract base class for logbook PDF templates
abstract class PdfBaseTemplate {
  /// The format info for this template
  ExportFormatInfo get formatInfo;

  /// Pilot name for the logbook cover/header
  final String pilotName;

  /// License number for the logbook cover/header
  final String? licenseNumber;

  /// Logo image bytes for the cover page
  final Uint8List logoBytes;

  /// Export date range start (optional filter)
  final DateTime? exportStartDate;

  /// Export date range end (optional filter)
  final DateTime? exportEndDate;

  PdfBaseTemplate({
    required this.pilotName,
    required this.logoBytes,
    this.licenseNumber,
    this.exportStartDate,
    this.exportEndDate,
  });

  /// Build the complete PDF document from a list of flights
  pw.Document buildDocument(List<LogbookEntry> flights) {
    final pdf = pw.Document(
      title: 'Pilot Logbook - $pilotName',
      author: 'HyperLog',
      creator: 'HyperLog Logbook Export',
    );

    // Sort flights by date (oldest first)
    final sortedFlights = List<LogbookEntry>.from(flights)
      ..sort((a, b) => a.flightDate.compareTo(b.flightDate));

    // Determine the actual date range from the flights
    DateTime? firstFlightDate;
    DateTime? lastFlightDate;
    if (sortedFlights.isNotEmpty) {
      firstFlightDate = sortedFlights.first.flightDate;
      lastFlightDate = sortedFlights.last.flightDate;
    }

    // Build cover page first
    buildCoverPage(
      pdf: pdf,
      firstFlightDate: exportStartDate ?? firstFlightDate,
      lastFlightDate: exportEndDate ?? lastFlightDate,
    );

    // Paginate flights
    final rowsPerPage = formatInfo.rowsPerPage;
    final cumulative = CumulativeTotals();

    for (int pageIndex = 0;
        pageIndex * rowsPerPage < sortedFlights.length;
        pageIndex++) {
      final start = pageIndex * rowsPerPage;
      final end = (start + rowsPerPage).clamp(0, sortedFlights.length);
      final pageFlights = sortedFlights.sublist(start, end);

      // Calculate page totals
      final pageTotals = PageTotals();
      for (final flight in pageFlights) {
        pageTotals.addEntry(flight);
      }

      // Build the page(s)
      buildPage(
        pdf: pdf,
        flights: pageFlights,
        pageNumber: pageIndex + 1,
        totalPages: (sortedFlights.length / rowsPerPage).ceil(),
        pageTotals: pageTotals,
        cumulativeTotals: cumulative.totals,
      );

      // Update cumulative totals for next page
      cumulative.addPageTotals(pageTotals);
    }

    // Handle empty logbook
    if (sortedFlights.isEmpty) {
      buildEmptyPage(pdf);
    }

    return pdf;
  }

  /// Build a page of the logbook (may be 1 or 2 physical pages for spreads)
  void buildPage({
    required pw.Document pdf,
    required List<LogbookEntry> flights,
    required int pageNumber,
    required int totalPages,
    required PageTotals pageTotals,
    required PageTotals cumulativeTotals,
  });

  /// Build the cover page with logo, pilot name, and date range
  void buildCoverPage({
    required pw.Document pdf,
    DateTime? firstFlightDate,
    DateTime? lastFlightDate,
  }) {
    final logoImage = pw.MemoryImage(logoBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: formatInfo.pageFormat.landscape,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                // Logo
                pw.Image(logoImage, width: 200),
                pw.SizedBox(height: 40),

                // Title
                pw.Text(
                  'PILOT LOGBOOK',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 40),

                // Pilot name
                pw.Text(
                  pilotName,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (licenseNumber != null) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    licenseNumber!,
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ],
                pw.SizedBox(height: 40),

                // Date range
                if (firstFlightDate != null || lastFlightDate != null) ...[
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'FLIGHT RECORDS',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          _formatDateRange(firstFlightDate, lastFlightDate),
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
                pw.SizedBox(height: 60),

                // Export date
                pw.Text(
                  'Exported on ${PdfFormatUtils.formatDateLong(DateTime.now())}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Format the date range for display
  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) {
      return 'All flights';
    }
    if (start != null && end != null) {
      return '${PdfFormatUtils.formatDateLong(start)} — ${PdfFormatUtils.formatDateLong(end)}';
    }
    if (start != null) {
      return 'From ${PdfFormatUtils.formatDateLong(start)}';
    }
    return 'Until ${PdfFormatUtils.formatDateLong(end!)}';
  }

  /// Build an empty page for logbooks with no flights
  void buildEmptyPage(pw.Document pdf) {
    pdf.addPage(
      pw.Page(
        pageFormat: formatInfo.pageFormat.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Pilot Logbook',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(pilotName, style: const pw.TextStyle(fontSize: 16)),
                if (licenseNumber != null) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(licenseNumber!,
                      style: const pw.TextStyle(fontSize: 12)),
                ],
                pw.SizedBox(height: 40),
                pw.Text(
                  'No flights recorded',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Common header builder
  pw.Widget buildHeader(String title, int pageNumber, int totalPages) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          'Page $pageNumber of $totalPages',
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  /// Common footer builder with HyperLog branding
  pw.Widget buildFooter() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Generated by HyperLog',
          style: pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey600,
          ),
        ),
        pw.Text(
          PdfFormatUtils.formatDateISO(DateTime.now()),
          style: pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  /// Common cell text style
  pw.TextStyle get cellStyle => const pw.TextStyle(fontSize: 8);

  /// Common header text style
  pw.TextStyle get headerStyle => pw.TextStyle(
        fontSize: 7,
        fontWeight: pw.FontWeight.bold,
      );

  /// Common total row text style
  pw.TextStyle get totalStyle => pw.TextStyle(
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
      );

  /// Minimum row height for consistent table appearance
  static const double minRowHeight = 14.0;

  /// Build a table cell with standard padding and fixed height
  pw.Widget cell(String text, {pw.Alignment? alignment}) {
    return pw.Container(
      height: minRowHeight,
      padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      alignment: alignment ?? pw.Alignment.center,
      child: pw.Text(text, style: cellStyle),
    );
  }

  /// Build a header cell with standard styling
  pw.Widget headerCell(String text, {int? maxLines}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 3),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: headerStyle,
        textAlign: pw.TextAlign.center,
        maxLines: maxLines,
      ),
    );
  }

  /// Build a total cell with bold styling and fixed height
  pw.Widget totalCell(String text) {
    return pw.Container(
      height: minRowHeight,
      padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      alignment: pw.Alignment.center,
      child: pw.Text(text, style: totalStyle),
    );
  }
}
