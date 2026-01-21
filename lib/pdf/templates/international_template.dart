import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../constants/export_format.dart';
import '../../models/logbook_entry.dart';
import '../pdf_base_template.dart';
import '../pdf_utils.dart';

/// International format template (Coradine style)
/// Single A4 page, 20 rows per page, balanced universal format
class InternationalTemplate extends PdfBaseTemplate {
  InternationalTemplate({
    required super.pilotName,
    super.licenseNumber,
  });

  @override
  ExportFormatInfo get formatInfo => ExportFormats.getInfo(LogbookExportFormat.international);

  @override
  void buildPage({
    required pw.Document pdf,
    required List<LogbookEntry> flights,
    required int pageNumber,
    required int totalPages,
    required PageTotals pageTotals,
    required PageTotals cumulativeTotals,
  }) {
    pdf.addPage(
      pw.Page(
        pageFormat: formatInfo.pageFormat.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              buildHeader('PILOT LOGBOOK - $pilotName', pageNumber, totalPages),
              pw.SizedBox(height: 10),

              // Flight table
              pw.Expanded(
                child: _buildFlightTable(flights, pageTotals, cumulativeTotals),
              ),

              // Footer
              pw.SizedBox(height: 10),
              buildFooter(),
            ],
          );
        },
      ),
    );
  }

  pw.Widget _buildFlightTable(
    List<LogbookEntry> flights,
    PageTotals pageTotals,
    PageTotals cumulativeTotals,
  ) {
    // Column widths (relative)
    final columnWidths = {
      0: const pw.FlexColumnWidth(1.2), // Date
      1: const pw.FlexColumnWidth(1.8), // Route
      2: const pw.FlexColumnWidth(1.0), // Type
      3: const pw.FlexColumnWidth(1.0), // Reg
      4: const pw.FlexColumnWidth(0.8), // Off
      5: const pw.FlexColumnWidth(0.8), // On
      6: const pw.FlexColumnWidth(0.8), // Total
      7: const pw.FlexColumnWidth(0.8), // Night
      8: const pw.FlexColumnWidth(0.8), // IFR
      9: const pw.FlexColumnWidth(0.8), // PIC
      10: const pw.FlexColumnWidth(0.8), // SIC
      11: const pw.FlexColumnWidth(0.8), // Dual
      12: const pw.FlexColumnWidth(0.8), // Instr
      13: const pw.FlexColumnWidth(0.8), // XC
      14: const pw.FlexColumnWidth(0.6), // Ldg
      15: const pw.FlexColumnWidth(1.5), // PIC Name
      16: const pw.FlexColumnWidth(2.0), // Remarks
    };

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: columnWidths,
      children: [
        // Header row
        _buildHeaderRow(),

        // Flight rows
        ...flights.map((f) => _buildFlightRow(f)),

        // Empty rows to fill page
        ...List.generate(
          formatInfo.rowsPerPage - flights.length,
          (_) => _buildEmptyRow(),
        ),

        // Page totals row
        _buildTotalsRow('PAGE TOTAL', pageTotals),

        // Cumulative totals row
        _buildTotalsRow('TOTAL TO DATE', cumulativeTotals),
      ],
    );
  }

  pw.TableRow _buildHeaderRow() {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey200),
      children: [
        headerCell('DATE'),
        headerCell('ROUTE'),
        headerCell('A/C\nTYPE'),
        headerCell('A/C\nREG'),
        headerCell('OFF'),
        headerCell('ON'),
        headerCell('TOTAL\nTIME'),
        headerCell('NIGHT'),
        headerCell('IFR'),
        headerCell('PIC'),
        headerCell('SIC'),
        headerCell('DUAL'),
        headerCell('INSTR'),
        headerCell('X-C'),
        headerCell('LDG'),
        headerCell('PIC NAME'),
        headerCell('REMARKS'),
      ],
    );
  }

  pw.TableRow _buildFlightRow(LogbookEntry entry) {
    return pw.TableRow(
      children: [
        cell(PdfFormatUtils.formatDateDDMMYY(entry.flightDate)),
        cell('${entry.dep}-${entry.dest}', alignment: pw.Alignment.centerLeft),
        cell(entry.aircraftType),
        cell(entry.aircraftReg),
        cell(PdfFormatUtils.formatTimeOfDay(entry.blockOff)),
        cell(PdfFormatUtils.formatTimeOfDay(entry.blockOn)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.total)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.night)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.ifr)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.pic)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.sic)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.dual)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.instructor)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.crossCountry)),
        cell(PdfFormatUtils.formatInt(entry.totalLandings.total)),
        cell(PdfFormatUtils.getPicName(entry), alignment: pw.Alignment.centerLeft),
        cell(PdfFormatUtils.getRemarks(entry), alignment: pw.Alignment.centerLeft),
      ],
    );
  }

  pw.TableRow _buildEmptyRow() {
    return pw.TableRow(
      children: List.generate(17, (_) => cell('')),
    );
  }

  pw.TableRow _buildTotalsRow(String label, PageTotals totals) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey100),
      children: [
        totalCell(label),
        totalCell(''),
        totalCell(''),
        totalCell(''),
        totalCell(''),
        totalCell(''),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.totalTime)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.night)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.ifr)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.pic)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.sic)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.dual)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.instructor)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.crossCountry)),
        totalCell(PdfFormatUtils.formatInt(totals.totalLandings)),
        totalCell(''),
        totalCell(''),
      ],
    );
  }
}
