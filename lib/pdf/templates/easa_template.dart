import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../constants/export_format.dart';
import '../../models/logbook_entry.dart';
import '../pdf_base_template.dart';
import '../pdf_utils.dart';

/// EASA format template
/// Two-page spread: Page A (flight details) + Page B (conditions/function time)
/// A4 format, 16 rows per page, per EASA-FCL standard
class EasaTemplate extends PdfBaseTemplate {
  EasaTemplate({
    required super.pilotName,
    required super.logoBytes,
    super.licenseNumber,
    super.exportStartDate,
    super.exportEndDate,
  });

  @override
  ExportFormatInfo get formatInfo => ExportFormats.getInfo(LogbookExportFormat.easa);

  @override
  void buildPage({
    required pw.Document pdf,
    required List<LogbookEntry> flights,
    required int pageNumber,
    required int totalPages,
    required PageTotals pageTotals,
    required PageTotals cumulativeTotals,
  }) {
    // Page A (left side) - Flight details
    pdf.addPage(
      pw.Page(
        pageFormat: formatInfo.pageFormat.landscape,
        margin: const pw.EdgeInsets.all(15),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageAHeader(pageNumber, totalPages),
              pw.SizedBox(height: 8),
              pw.Expanded(
                child: _buildPageATable(flights, pageTotals, cumulativeTotals),
              ),
              pw.SizedBox(height: 8),
              buildFooter(),
            ],
          );
        },
      ),
    );

    // Page B (right side) - Conditions and function time
    pdf.addPage(
      pw.Page(
        pageFormat: formatInfo.pageFormat.landscape,
        margin: const pw.EdgeInsets.all(15),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageBHeader(pageNumber, totalPages),
              pw.SizedBox(height: 8),
              pw.Expanded(
                child: _buildPageBTable(flights, pageTotals, cumulativeTotals),
              ),
              pw.SizedBox(height: 8),
              buildFooter(),
            ],
          );
        },
      ),
    );
  }

  pw.Widget _buildPageAHeader(int pageNumber, int totalPages) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'PILOT LOGBOOK - EASA FORMAT',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(pilotName, style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.Text('Page $pageNumber A', style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  pw.Widget _buildPageBHeader(int pageNumber, int totalPages) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'OPERATIONAL CONDITIONS / PILOT FUNCTION TIME',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text('Page $pageNumber B', style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  // PAGE A TABLE - Flight details
  pw.Widget _buildPageATable(
    List<LogbookEntry> flights,
    PageTotals pageTotals,
    PageTotals cumulativeTotals,
  ) {
    final columnWidths = {
      0: const pw.FlexColumnWidth(1.2), // Date
      1: const pw.FlexColumnWidth(1.0), // Dep Place
      2: const pw.FlexColumnWidth(0.8), // Dep Time
      3: const pw.FlexColumnWidth(1.0), // Arr Place
      4: const pw.FlexColumnWidth(0.8), // Arr Time
      5: const pw.FlexColumnWidth(1.2), // Aircraft Type
      6: const pw.FlexColumnWidth(1.0), // Aircraft Reg
      7: const pw.FlexColumnWidth(0.9), // SE Time
      8: const pw.FlexColumnWidth(0.9), // ME Time
      9: const pw.FlexColumnWidth(0.9), // Total Time
    };

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: columnWidths,
      children: [
        // Section header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _sectionHeader('1 DATE', 1),
            _sectionHeader('2 DEPARTURE', 2),
            _sectionHeader('3 ARRIVAL', 2),
            _sectionHeader('4 AIRCRAFT', 2),
            _sectionHeader('5 SINGLE PILOT TIME', 3),
          ],
        ),
        // Column headers
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            headerCell(''),
            headerCell('PLACE'),
            headerCell('TIME'),
            headerCell('PLACE'),
            headerCell('TIME'),
            headerCell('TYPE'),
            headerCell('REG'),
            headerCell('SE'),
            headerCell('ME'),
            headerCell('TOTAL'),
          ],
        ),
        // Flight rows
        ...flights.map((f) => _buildPageAFlightRow(f)),
        // Empty rows
        ...List.generate(
          formatInfo.rowsPerPage - flights.length,
          (_) => _buildPageAEmptyRow(),
        ),
        // Page totals
        _buildPageATotalsRow('THIS PAGE', pageTotals),
        // Cumulative totals
        _buildPageATotalsRow('TOTAL FROM\nPREVIOUS PAGES', cumulativeTotals),
        // Grand total
        _buildPageATotalsRow(
          'TOTAL TIME',
          PageTotals(
            totalTime: pageTotals.totalTime + cumulativeTotals.totalTime,
            multiEngine: pageTotals.multiEngine + cumulativeTotals.multiEngine,
          ),
        ),
      ],
    );
  }

  pw.Widget _sectionHeader(String text, int colspan) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.TableRow _buildPageAFlightRow(LogbookEntry entry) {
    final isME = entry.flightTime.multiEngine > 0;
    final seTime = isME ? 0 : entry.flightTime.total;
    final meTime = isME ? entry.flightTime.total : 0;

    return pw.TableRow(
      children: [
        cell(PdfFormatUtils.formatDateDDMMYY(entry.flightDate)),
        cell(entry.dep),
        cell(PdfFormatUtils.formatTimeOfDay(entry.blockOff)),
        cell(entry.dest),
        cell(PdfFormatUtils.formatTimeOfDay(entry.blockOn)),
        cell(entry.aircraftType),
        cell(entry.displayReg),
        cell(PdfFormatUtils.formatMinutesAsHHMM(seTime)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(meTime)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.total)),
      ],
    );
  }

  pw.TableRow _buildPageAEmptyRow() {
    return pw.TableRow(
      children: List.generate(10, (_) => cell('')),
    );
  }

  pw.TableRow _buildPageATotalsRow(String label, PageTotals totals) {
    final seTime = totals.totalTime - totals.multiEngine;
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey100),
      children: [
        totalCell(label),
        totalCell(''),
        totalCell(''),
        totalCell(''),
        totalCell(''),
        totalCell(''),
        totalCell(''),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(seTime)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.multiEngine)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.totalTime)),
      ],
    );
  }

  // PAGE B TABLE - Conditions and function time
  pw.Widget _buildPageBTable(
    List<LogbookEntry> flights,
    PageTotals pageTotals,
    PageTotals cumulativeTotals,
  ) {
    final columnWidths = {
      0: const pw.FlexColumnWidth(0.8), // Night
      1: const pw.FlexColumnWidth(0.8), // IFR
      2: const pw.FlexColumnWidth(0.8), // PIC
      3: const pw.FlexColumnWidth(0.8), // Co-Pilot
      4: const pw.FlexColumnWidth(0.8), // Dual
      5: const pw.FlexColumnWidth(0.8), // Instructor
      6: const pw.FlexColumnWidth(0.6), // Day Ldg
      7: const pw.FlexColumnWidth(0.6), // Night Ldg
      8: const pw.FlexColumnWidth(1.5), // PIC Name
      9: const pw.FlexColumnWidth(2.5), // Remarks
    };

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: columnWidths,
      children: [
        // Section header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _sectionHeader('6 OPERATIONAL\nCONDITION TIME', 2),
            _sectionHeader('7 PILOT FUNCTION TIME', 4),
            _sectionHeader('8 LANDINGS', 2),
            _sectionHeader('9', 1),
            _sectionHeader('10', 1),
          ],
        ),
        // Column headers
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            headerCell('NIGHT'),
            headerCell('IFR'),
            headerCell('PIC'),
            headerCell('CO-PILOT'),
            headerCell('DUAL'),
            headerCell('INSTR'),
            headerCell('DAY'),
            headerCell('NIGHT'),
            headerCell('NAME PIC'),
            headerCell('REMARKS AND ENDORSEMENTS'),
          ],
        ),
        // Flight rows
        ...flights.map((f) => _buildPageBFlightRow(f)),
        // Empty rows
        ...List.generate(
          formatInfo.rowsPerPage - flights.length,
          (_) => _buildPageBEmptyRow(),
        ),
        // Page totals
        _buildPageBTotalsRow('THIS PAGE', pageTotals),
        // Cumulative totals
        _buildPageBTotalsRow('TOTAL FROM\nPREVIOUS PAGES', cumulativeTotals),
        // Grand total
        _buildPageBTotalsRow(
          'TOTAL TIME',
          PageTotals(
            night: pageTotals.night + cumulativeTotals.night,
            ifr: pageTotals.ifr + cumulativeTotals.ifr,
            pic: pageTotals.pic + cumulativeTotals.pic,
            sic: pageTotals.sic + cumulativeTotals.sic,
            dual: pageTotals.dual + cumulativeTotals.dual,
            instructor: pageTotals.instructor + cumulativeTotals.instructor,
            dayLandings: pageTotals.dayLandings + cumulativeTotals.dayLandings,
            nightLandings: pageTotals.nightLandings + cumulativeTotals.nightLandings,
          ),
        ),
      ],
    );
  }

  pw.TableRow _buildPageBFlightRow(LogbookEntry entry) {
    return pw.TableRow(
      children: [
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.night)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.ifr)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.pic)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.sic)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.dual)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.instructor)),
        cell(PdfFormatUtils.formatInt(entry.totalLandings.day)),
        cell(PdfFormatUtils.formatInt(entry.totalLandings.night)),
        cell(PdfFormatUtils.getPicName(entry), alignment: pw.Alignment.centerLeft),
        cell(PdfFormatUtils.getRemarks(entry), alignment: pw.Alignment.centerLeft),
      ],
    );
  }

  pw.TableRow _buildPageBEmptyRow() {
    return pw.TableRow(
      children: List.generate(10, (_) => cell('')),
    );
  }

  pw.TableRow _buildPageBTotalsRow(String label, PageTotals totals) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey100),
      children: [
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.night)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.ifr)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.pic)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.sic)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.dual)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.instructor)),
        totalCell(PdfFormatUtils.formatInt(totals.dayLandings)),
        totalCell(PdfFormatUtils.formatInt(totals.nightLandings)),
        totalCell(''),
        totalCell(label),
      ],
    );
  }
}
