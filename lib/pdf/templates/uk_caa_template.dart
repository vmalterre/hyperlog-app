import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../constants/export_format.dart';
import '../../models/logbook_entry.dart';
import '../pdf_base_template.dart';
import '../pdf_utils.dart';

/// UK CAA format template
/// Two-page spread with UK-specific terminology and SE/ME day/night breakdown
/// A4 format, 18 rows per page
class UkCaaTemplate extends PdfBaseTemplate {
  UkCaaTemplate({
    required super.pilotName,
    required super.logoBytes,
    super.licenseNumber,
    super.exportStartDate,
    super.exportEndDate,
  });

  @override
  ExportFormatInfo get formatInfo => ExportFormats.getInfo(LogbookExportFormat.ukCaa);

  @override
  void buildPage({
    required pw.Document pdf,
    required List<LogbookEntry> flights,
    required int pageNumber,
    required int totalPages,
    required PageTotals pageTotals,
    required PageTotals cumulativeTotals,
  }) {
    // Page A - Flight details
    pdf.addPage(
      pw.Page(
        pageFormat: formatInfo.pageFormat.landscape,
        margin: const pw.EdgeInsets.all(15),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader('FLIGHT DETAILS', pageNumber, totalPages, 'A'),
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

    // Page B - Pilot function time
    pdf.addPage(
      pw.Page(
        pageFormat: formatInfo.pageFormat.landscape,
        margin: const pw.EdgeInsets.all(15),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader('PILOT FUNCTION TIME', pageNumber, totalPages, 'B'),
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

  pw.Widget _buildPageHeader(String title, int pageNumber, int totalPages, String side) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'PILOT\'S PERSONAL FLYING LOG BOOK - UK CAA',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(pilotName, style: const pw.TextStyle(fontSize: 9)),
            if (licenseNumber != null)
              pw.Text('Licence No: $licenseNumber', style: const pw.TextStyle(fontSize: 8)),
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
      0: const pw.FlexColumnWidth(1.1), // Date
      1: const pw.FlexColumnWidth(1.1), // Type
      2: const pw.FlexColumnWidth(1.0), // Reg
      3: const pw.FlexColumnWidth(0.9), // PIC
      4: const pw.FlexColumnWidth(0.8), // From
      5: const pw.FlexColumnWidth(0.7), // Dep Time
      6: const pw.FlexColumnWidth(0.8), // To
      7: const pw.FlexColumnWidth(0.7), // Arr Time
      8: const pw.FlexColumnWidth(0.8), // SE Day
      9: const pw.FlexColumnWidth(0.8), // SE Night
      10: const pw.FlexColumnWidth(0.8), // ME Day
      11: const pw.FlexColumnWidth(0.8), // ME Night
      12: const pw.FlexColumnWidth(0.8), // Inst
      13: const pw.FlexColumnWidth(0.8), // Total
    };

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: columnWidths,
      children: [
        // Section headers
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _sectionCell('DATE', 1),
            _sectionCell('AIRCRAFT', 2),
            _sectionCell('PILOT\nIN COMMAND', 1),
            _sectionCell('DEPARTURE', 2),
            _sectionCell('ARRIVAL', 2),
            _sectionCell('SINGLE\nENGINE', 2),
            _sectionCell('MULTI\nENGINE', 2),
            _sectionCell('INST', 1),
            _sectionCell('TOTAL', 1),
          ],
        ),
        // Sub-headers
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            headerCell(''),
            headerCell('TYPE'),
            headerCell('REG'),
            headerCell('NAME'),
            headerCell('FROM'),
            headerCell('TIME'),
            headerCell('TO'),
            headerCell('TIME'),
            headerCell('DAY'),
            headerCell('NIGHT'),
            headerCell('DAY'),
            headerCell('NIGHT'),
            headerCell(''),
            headerCell(''),
          ],
        ),
        // Flight rows
        ...flights.map((f) => _buildPageAFlightRow(f)),
        // Empty rows
        ...List.generate(
          formatInfo.rowsPerPage - flights.length,
          (_) => _buildEmptyRow(14),
        ),
        // Totals
        _buildPageATotalsRow('THIS PAGE', pageTotals),
        _buildPageATotalsRow('BROUGHT FORWARD', cumulativeTotals),
        _buildPageATotalsRow('TOTALS', _addTotals(pageTotals, cumulativeTotals)),
      ],
    );
  }

  pw.Widget _sectionCell(String text, int span) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 3),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.TableRow _buildPageAFlightRow(LogbookEntry entry) {
    final isME = entry.flightTime.multiEngine > 0;
    final dayTime = entry.flightTime.total - entry.flightTime.night;

    // Calculate SE/ME day/night split
    final seDay = isME ? 0 : dayTime;
    final seNight = isME ? 0 : entry.flightTime.night;
    final meDay = isME ? dayTime : 0;
    final meNight = isME ? entry.flightTime.night : 0;

    return pw.TableRow(
      children: [
        cell(PdfFormatUtils.formatDateDDMMYY(entry.flightDate)),
        cell(entry.aircraftType),
        cell(entry.aircraftReg),
        cell(PdfFormatUtils.getPicName(entry)),
        cell(entry.dep),
        cell(PdfFormatUtils.formatTimeOfDay(entry.blockOff)),
        cell(entry.dest),
        cell(PdfFormatUtils.formatTimeOfDay(entry.blockOn)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(seDay)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(seNight)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(meDay)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(meNight)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.ifr)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.total)),
      ],
    );
  }

  pw.TableRow _buildEmptyRow(int cols) {
    return pw.TableRow(
      children: List.generate(cols, (_) => cell('')),
    );
  }

  pw.TableRow _buildPageATotalsRow(String label, PageTotals totals) {
    final seTime = totals.totalTime - totals.multiEngine;
    final seNight = (totals.night * seTime / (totals.totalTime > 0 ? totals.totalTime : 1)).round();
    final seDay = seTime - seNight;
    final meNight = totals.night - seNight;
    final meDay = totals.multiEngine - meNight;

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
        totalCell(''),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(seDay.clamp(0, 999999))),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(seNight.clamp(0, 999999))),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(meDay.clamp(0, 999999))),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(meNight.clamp(0, 999999))),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.ifr)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.totalTime)),
      ],
    );
  }

  // PAGE B - Pilot function time
  pw.Widget _buildPageBTable(
    List<LogbookEntry> flights,
    PageTotals pageTotals,
    PageTotals cumulativeTotals,
  ) {
    final columnWidths = {
      0: const pw.FlexColumnWidth(0.9), // P1/Capt
      1: const pw.FlexColumnWidth(0.9), // P1 u/s
      2: const pw.FlexColumnWidth(0.9), // P2/Co-Pilot
      3: const pw.FlexColumnWidth(0.9), // PUT
      4: const pw.FlexColumnWidth(0.9), // Instructor
      5: const pw.FlexColumnWidth(0.9), // Examiner
      6: const pw.FlexColumnWidth(0.6), // Day Ldg
      7: const pw.FlexColumnWidth(0.6), // Night Ldg
      8: const pw.FlexColumnWidth(0.6), // Day T/O
      9: const pw.FlexColumnWidth(0.6), // Night T/O
      10: const pw.FlexColumnWidth(3.0), // Remarks
    };

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: columnWidths,
      children: [
        // Section headers
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _sectionCell('PILOT FUNCTION TIME', 6),
            _sectionCell('LANDINGS', 2),
            _sectionCell('TAKE-OFFS', 2),
            _sectionCell('REMARKS', 1),
          ],
        ),
        // Sub-headers
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            headerCell('P1/\nCAPT'),
            headerCell('P1 u/s'),
            headerCell('P2/\nCO-PLT'),
            headerCell('PUT'),
            headerCell('INSTR'),
            headerCell('EXAM'),
            headerCell('DAY'),
            headerCell('NIGHT'),
            headerCell('DAY'),
            headerCell('NIGHT'),
            headerCell(''),
          ],
        ),
        // Flight rows
        ...flights.map((f) => _buildPageBFlightRow(f)),
        // Empty rows
        ...List.generate(
          formatInfo.rowsPerPage - flights.length,
          (_) => _buildEmptyRow(11),
        ),
        // Totals
        _buildPageBTotalsRow('THIS PAGE', pageTotals),
        _buildPageBTotalsRow('BROUGHT FORWARD', cumulativeTotals),
        _buildPageBTotalsRow('TOTALS', _addTotals(pageTotals, cumulativeTotals)),
      ],
    );
  }

  pw.TableRow _buildPageBFlightRow(LogbookEntry entry) {
    return pw.TableRow(
      children: [
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.pic)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.picus)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.sic)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.dual)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.instructor)),
        cell(''), // Examiner time - not tracked
        cell(PdfFormatUtils.formatInt(entry.totalLandings.day)),
        cell(PdfFormatUtils.formatInt(entry.totalLandings.night)),
        cell(PdfFormatUtils.formatInt(entry.totalTakeoffs.day)),
        cell(PdfFormatUtils.formatInt(entry.totalTakeoffs.night)),
        cell(PdfFormatUtils.getRemarks(entry), alignment: pw.Alignment.centerLeft),
      ],
    );
  }

  pw.TableRow _buildPageBTotalsRow(String label, PageTotals totals) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey100),
      children: [
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.pic)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.picus)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.sic)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.dual)),
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.instructor)),
        totalCell(''),
        totalCell(PdfFormatUtils.formatInt(totals.dayLandings)),
        totalCell(PdfFormatUtils.formatInt(totals.nightLandings)),
        totalCell(PdfFormatUtils.formatInt(totals.dayTakeoffs)),
        totalCell(PdfFormatUtils.formatInt(totals.nightTakeoffs)),
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
