import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../constants/export_format.dart';
import '../../models/logbook_entry.dart';
import '../pdf_base_template.dart';
import '../pdf_utils.dart';

/// French DGAC format template
/// A5 format, bilingual French/English headers, 12 rows per page
class DgacTemplate extends PdfBaseTemplate {
  DgacTemplate({
    required super.pilotName,
    super.licenseNumber,
  });

  @override
  ExportFormatInfo get formatInfo => ExportFormats.getInfo(LogbookExportFormat.dgac);

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
        margin: const pw.EdgeInsets.all(10),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(pageNumber, totalPages),
              pw.SizedBox(height: 6),
              pw.Expanded(
                child: _buildFlightTable(flights, pageTotals, cumulativeTotals),
              ),
              pw.SizedBox(height: 6),
              _buildBilingualFooter(),
            ],
          );
        },
      ),
    );
  }

  pw.Widget _buildHeader(int pageNumber, int totalPages) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'CARNET DE VOL / FLIGHT LOG',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Nom / Name: $pilotName',
              style: const pw.TextStyle(fontSize: 8),
            ),
            if (licenseNumber != null)
              pw.Text(
                'Licence: $licenseNumber',
                style: const pw.TextStyle(fontSize: 8),
              ),
          ],
        ),
        pw.Text(
          'Page $pageNumber / $totalPages',
          style: const pw.TextStyle(fontSize: 8),
        ),
      ],
    );
  }

  pw.Widget _buildFlightTable(
    List<LogbookEntry> flights,
    PageTotals pageTotals,
    PageTotals cumulativeTotals,
  ) {
    final columnWidths = {
      0: const pw.FlexColumnWidth(1.0), // Date
      1: const pw.FlexColumnWidth(1.4), // Route
      2: const pw.FlexColumnWidth(1.0), // Type
      3: const pw.FlexColumnWidth(0.9), // Immat
      4: const pw.FlexColumnWidth(0.6), // Bloc Off
      5: const pw.FlexColumnWidth(0.6), // Bloc On
      6: const pw.FlexColumnWidth(0.7), // Total
      7: const pw.FlexColumnWidth(0.7), // Nuit/Night
      8: const pw.FlexColumnWidth(0.7), // IFR
      9: const pw.FlexColumnWidth(0.7), // CDB/PIC
      10: const pw.FlexColumnWidth(0.7), // DC/Dual
      11: const pw.FlexColumnWidth(0.5), // Att/Ldg
      12: const pw.FlexColumnWidth(1.5), // Observations
    };

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: columnWidths,
      children: [
        // Bilingual headers
        _buildBilingualHeaderRow(),
        // Flight rows
        ...flights.map((f) => _buildFlightRow(f)),
        // Empty rows
        ...List.generate(
          formatInfo.rowsPerPage - flights.length,
          (_) => _buildEmptyRow(),
        ),
        // Page totals
        _buildTotalsRow('TOTAL PAGE', pageTotals),
        // Cumulative totals
        _buildTotalsRow('REPORT / CARRIED FORWARD', cumulativeTotals),
        // Grand total
        _buildTotalsRow('TOTAL GENERAL', _addTotals(pageTotals, cumulativeTotals)),
      ],
    );
  }

  pw.TableRow _buildBilingualHeaderRow() {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey200),
      children: [
        _bilingualHeader('DATE', 'DATE'),
        _bilingualHeader('TRAJET', 'ROUTE'),
        _bilingualHeader('TYPE', 'TYPE'),
        _bilingualHeader('IMMAT', 'REG'),
        _bilingualHeader('DEP', 'OFF'),
        _bilingualHeader('ARR', 'ON'),
        _bilingualHeader('TOTAL', 'TOTAL'),
        _bilingualHeader('NUIT', 'NIGHT'),
        _bilingualHeader('IFR', 'IFR'),
        _bilingualHeader('CDB', 'PIC'),
        _bilingualHeader('DC', 'DUAL'),
        _bilingualHeader('ATT', 'LDG'),
        _bilingualHeader('OBSERVATIONS', 'REMARKS'),
      ],
    );
  }

  pw.Widget _bilingualHeader(String french, String english) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 1, vertical: 2),
      alignment: pw.Alignment.center,
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            french,
            style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            english,
            style: pw.TextStyle(fontSize: 5, fontWeight: pw.FontWeight.normal, fontStyle: pw.FontStyle.italic),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  pw.TableRow _buildFlightRow(LogbookEntry entry) {
    return pw.TableRow(
      children: [
        cell(PdfFormatUtils.formatDateDDMMYY(entry.flightDate)),
        cell('${entry.dep}-${entry.dest}'),
        cell(entry.aircraftType),
        cell(entry.aircraftReg),
        cell(PdfFormatUtils.formatTimeOfDay(entry.blockOff)),
        cell(PdfFormatUtils.formatTimeOfDay(entry.blockOn)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.total)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.night)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.ifr)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.pic)),
        cell(PdfFormatUtils.formatMinutesAsHHMM(entry.flightTime.dual)),
        cell(PdfFormatUtils.formatInt(entry.totalLandings.total)),
        cell(PdfFormatUtils.getRemarks(entry), alignment: pw.Alignment.centerLeft),
      ],
    );
  }

  pw.TableRow _buildEmptyRow() {
    return pw.TableRow(
      children: List.generate(13, (_) => cell('')),
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
        totalCell(PdfFormatUtils.formatMinutesAsHHMM(totals.dual)),
        totalCell(PdfFormatUtils.formatInt(totals.totalLandings)),
        totalCell(''),
      ],
    );
  }

  pw.Widget _buildBilingualFooter() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Généré par HyperLog / Generated by HyperLog',
          style: pw.TextStyle(fontSize: 6, color: PdfColors.grey600),
        ),
        pw.Text(
          PdfFormatUtils.formatDateISO(DateTime.now()),
          style: pw.TextStyle(fontSize: 6, color: PdfColors.grey600),
        ),
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
