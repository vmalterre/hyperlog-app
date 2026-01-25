import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../constants/export_format.dart';
import '../../models/logbook_entry.dart';
import '../pdf_base_template.dart';
import '../pdf_utils.dart';

/// FAA format template (Jeppesen Pro style)
/// Two-page spread: Page A (flight details) + Page B (piloting time categories)
/// US Letter format, 27 rows per page
class FaaTemplate extends PdfBaseTemplate {
  FaaTemplate({
    required super.pilotName,
    required super.logoBytes,
    super.licenseNumber,
    super.exportStartDate,
    super.exportEndDate,
  });

  @override
  ExportFormatInfo get formatInfo => ExportFormats.getInfo(LogbookExportFormat.faa);

  @override
  void buildPage({
    required pw.Document pdf,
    required List<LogbookEntry> flights,
    required int pageNumber,
    required int totalPages,
    required PageTotals pageTotals,
    required PageTotals cumulativeTotals,
  }) {
    // Page A - Flight details and aircraft
    pdf.addPage(
      pw.Page(
        pageFormat: formatInfo.pageFormat.landscape,
        margin: const pw.EdgeInsets.all(12),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader('FLIGHT RECORD', pageNumber, totalPages, 'A'),
              pw.SizedBox(height: 6),
              pw.Expanded(
                child: _buildPageATable(flights, pageTotals, cumulativeTotals),
              ),
              pw.SizedBox(height: 6),
              buildFooter(),
            ],
          );
        },
      ),
    );

    // Page B - Piloting time categories
    pdf.addPage(
      pw.Page(
        pageFormat: formatInfo.pageFormat.landscape,
        margin: const pw.EdgeInsets.all(12),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader('PILOTING TIME', pageNumber, totalPages, 'B'),
              pw.SizedBox(height: 6),
              pw.Expanded(
                child: _buildPageBTable(flights, pageTotals, cumulativeTotals),
              ),
              pw.SizedBox(height: 6),
              buildFooter(),
            ],
          );
        },
      ),
    );
  }

  pw.Widget _buildPageHeader(String title, int pageNumber, int totalPages, String side) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'PILOT LOGBOOK - FAA FORMAT',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('$pilotName${licenseNumber != null ? ' - $licenseNumber' : ''}',
                style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(title,
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.Text('Page $pageNumber$side', style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
      ],
    );
  }

  // PAGE A - Flight details
  pw.Widget _buildPageATable(
    List<LogbookEntry> flights,
    PageTotals pageTotals,
    PageTotals cumulativeTotals,
  ) {
    final columnWidths = {
      0: const pw.FlexColumnWidth(1.0), // Date
      1: const pw.FlexColumnWidth(1.2), // Aircraft Type
      2: const pw.FlexColumnWidth(1.0), // Aircraft Ident
      3: const pw.FlexColumnWidth(0.8), // From
      4: const pw.FlexColumnWidth(0.8), // To
      5: const pw.FlexColumnWidth(0.7), // No. Inst App
      6: const pw.FlexColumnWidth(0.7), // No. Ldg Day
      7: const pw.FlexColumnWidth(0.7), // No. Ldg Night
      8: const pw.FlexColumnWidth(1.0), // Airplane SEL
      9: const pw.FlexColumnWidth(1.0), // Airplane MEL
      10: const pw.FlexColumnWidth(1.0), // Cross-Country
      11: const pw.FlexColumnWidth(1.0), // Night
      12: const pw.FlexColumnWidth(1.0), // Actual Inst
      13: const pw.FlexColumnWidth(1.0), // Total Duration
    };

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: columnWidths,
      children: [
        // Section headers
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _headerCell('DATE', 1),
            _headerCell('AIRCRAFT', 2),
            _headerCell('ROUTE OF\nFLIGHT', 2),
            _headerCell('NO.\nINST\nAPP', 1),
            _headerCell('NO. LANDINGS', 2),
            _headerCell('AIRCRAFT CATEGORY AND CLASS', 4),
            _headerCell('TOTAL\nDURATION\nOF FLIGHT', 1),
          ],
        ),
        // Sub-headers
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            headerCell(''),
            headerCell('MAKE &\nMODEL'),
            headerCell('IDENT'),
            headerCell('FROM'),
            headerCell('TO'),
            headerCell(''),
            headerCell('DAY'),
            headerCell('NIGHT'),
            headerCell('ASEL'),
            headerCell('AMEL'),
            headerCell('CROSS\nCOUNTRY'),
            headerCell('NIGHT'),
            headerCell('ACTUAL\nINSTR'),
            headerCell(''),
          ],
        ),
        // Flight rows
        ...flights.map((f) => _buildPageAFlightRow(f)),
        // Empty rows to fill page
        ...List.generate(
          formatInfo.rowsPerPage - flights.length,
          (_) => _buildEmptyRow(14),
        ),
        // Totals
        _buildPageATotalsRow('PAGE TOTALS', pageTotals),
        _buildPageATotalsRow('TOTALS FORWARDED', cumulativeTotals),
        _buildPageATotalsRow('TOTALS THIS PAGE', _addTotals(pageTotals, cumulativeTotals)),
      ],
    );
  }

  pw.Widget _headerCell(String text, int span) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 3),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.TableRow _buildPageAFlightRow(LogbookEntry entry) {
    final isME = entry.flightTime.multiEngine > 0;
    final asel = isME ? 0 : entry.flightTime.total;
    final amel = isME ? entry.flightTime.total : 0;

    return pw.TableRow(
      children: [
        cell(PdfFormatUtils.formatDateMMDDYY(entry.flightDate)),
        cell(entry.aircraftType),
        cell(entry.displayReg),
        cell(entry.dep),
        cell(entry.dest),
        cell(PdfFormatUtils.formatInt(entry.approaches.total)),
        cell(PdfFormatUtils.formatInt(entry.totalLandings.day)),
        cell(PdfFormatUtils.formatInt(entry.totalLandings.night)),
        cell(PdfFormatUtils.formatMinutesAsDecimal(asel)),
        cell(PdfFormatUtils.formatMinutesAsDecimal(amel)),
        cell(PdfFormatUtils.formatMinutesAsDecimal(entry.flightTime.crossCountry)),
        cell(PdfFormatUtils.formatMinutesAsDecimal(entry.flightTime.night)),
        cell(PdfFormatUtils.formatMinutesAsDecimal(entry.flightTime.ifr)),
        cell(PdfFormatUtils.formatMinutesAsDecimal(entry.flightTime.total)),
      ],
    );
  }

  pw.TableRow _buildEmptyRow(int cols) {
    return pw.TableRow(
      children: List.generate(cols, (_) => cell('')),
    );
  }

  pw.TableRow _buildPageATotalsRow(String label, PageTotals totals) {
    final asel = totals.totalTime - totals.multiEngine;
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey100),
      children: [
        totalCell(label),
        totalCell(''),
        totalCell(''),
        totalCell(''),
        totalCell(''),
        totalCell(''),
        totalCell(PdfFormatUtils.formatInt(totals.dayLandings)),
        totalCell(PdfFormatUtils.formatInt(totals.nightLandings)),
        totalCell(PdfFormatUtils.formatMinutesAsDecimal(asel)),
        totalCell(PdfFormatUtils.formatMinutesAsDecimal(totals.multiEngine)),
        totalCell(PdfFormatUtils.formatMinutesAsDecimal(totals.crossCountry)),
        totalCell(PdfFormatUtils.formatMinutesAsDecimal(totals.night)),
        totalCell(PdfFormatUtils.formatMinutesAsDecimal(totals.ifr)),
        totalCell(PdfFormatUtils.formatMinutesAsDecimal(totals.totalTime)),
      ],
    );
  }

  // PAGE B - Piloting time
  pw.Widget _buildPageBTable(
    List<LogbookEntry> flights,
    PageTotals pageTotals,
    PageTotals cumulativeTotals,
  ) {
    final columnWidths = {
      0: const pw.FlexColumnWidth(1.0), // Solo
      1: const pw.FlexColumnWidth(1.0), // PIC
      2: const pw.FlexColumnWidth(1.0), // SIC
      3: const pw.FlexColumnWidth(1.0), // Flight Training Received
      4: const pw.FlexColumnWidth(1.0), // Flight Training Given
      5: const pw.FlexColumnWidth(1.0), // Sim Inst
      6: const pw.FlexColumnWidth(1.0), // FTD
      7: const pw.FlexColumnWidth(1.0), // ATD
      8: const pw.FlexColumnWidth(3.0), // Remarks
    };

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: columnWidths,
      children: [
        // Section headers
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _headerCell('PILOT TIME', 5),
            _headerCell('GROUND\nTRAINER', 3),
            _headerCell('REMARKS, PROCEDURES,\nMANEUVERS', 1),
          ],
        ),
        // Sub-headers
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            headerCell('SOLO'),
            headerCell('PILOT IN\nCOMMAND'),
            headerCell('SECOND IN\nCOMMAND'),
            headerCell('FLIGHT\nTRAINING\nRECEIVED'),
            headerCell('FLIGHT\nTRAINING\nGIVEN'),
            headerCell('SIM.\nINSTR.'),
            headerCell('FTD'),
            headerCell('ATD'),
            headerCell(''),
          ],
        ),
        // Flight rows
        ...flights.map((f) => _buildPageBFlightRow(f)),
        // Empty rows
        ...List.generate(
          formatInfo.rowsPerPage - flights.length,
          (_) => _buildEmptyRow(9),
        ),
        // Totals
        _buildPageBTotalsRow('PAGE TOTALS', pageTotals),
        _buildPageBTotalsRow('TOTALS FORWARDED', cumulativeTotals),
        _buildPageBTotalsRow('TOTALS THIS PAGE', _addTotals(pageTotals, cumulativeTotals)),
      ],
    );
  }

  pw.TableRow _buildPageBFlightRow(LogbookEntry entry) {
    return pw.TableRow(
      children: [
        cell(PdfFormatUtils.formatMinutesAsDecimal(entry.flightTime.solo)),
        cell(PdfFormatUtils.formatMinutesAsDecimal(entry.flightTime.pic)),
        cell(PdfFormatUtils.formatMinutesAsDecimal(entry.flightTime.sic)),
        cell(PdfFormatUtils.formatMinutesAsDecimal(entry.flightTime.dual)),
        cell(PdfFormatUtils.formatMinutesAsDecimal(entry.flightTime.instructor)),
        cell(''), // Sim Inst - not tracked
        cell(''), // FTD - not tracked
        cell(''), // ATD - not tracked
        cell(PdfFormatUtils.getRemarks(entry), alignment: pw.Alignment.centerLeft),
      ],
    );
  }

  pw.TableRow _buildPageBTotalsRow(String label, PageTotals totals) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey100),
      children: [
        totalCell(PdfFormatUtils.formatMinutesAsDecimal(totals.totalTime - totals.pic - totals.sic - totals.dual)), // Solo approximation
        totalCell(PdfFormatUtils.formatMinutesAsDecimal(totals.pic)),
        totalCell(PdfFormatUtils.formatMinutesAsDecimal(totals.sic)),
        totalCell(PdfFormatUtils.formatMinutesAsDecimal(totals.dual)),
        totalCell(PdfFormatUtils.formatMinutesAsDecimal(totals.instructor)),
        totalCell(''),
        totalCell(''),
        totalCell(''),
        totalCell(label),
      ],
    );
  }

  PageTotals _addTotals(PageTotals a, PageTotals b) {
    return PageTotals(
      totalTime: a.totalTime + b.totalTime,
      night: a.night + b.night,
      ifr: a.ifr + b.ifr,
      pic: a.pic + b.pic,
      picus: a.picus + b.picus,
      sic: a.sic + b.sic,
      dual: a.dual + b.dual,
      instructor: a.instructor + b.instructor,
      multiEngine: a.multiEngine + b.multiEngine,
      crossCountry: a.crossCountry + b.crossCountry,
      dayLandings: a.dayLandings + b.dayLandings,
      nightLandings: a.nightLandings + b.nightLandings,
      dayTakeoffs: a.dayTakeoffs + b.dayTakeoffs,
      nightTakeoffs: a.nightTakeoffs + b.nightTakeoffs,
    );
  }
}
