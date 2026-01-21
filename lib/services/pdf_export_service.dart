import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/export_format.dart';
import '../models/logbook_entry.dart';
import '../pdf/pdf_base_template.dart';
import '../pdf/templates/international_template.dart';
import '../pdf/templates/easa_template.dart';
import '../pdf/templates/faa_template.dart';
import '../pdf/templates/uk_caa_template.dart';
import '../pdf/templates/dgac_template.dart';

/// Service for generating and exporting logbook PDFs
class PdfExportService {
  /// Generate a PDF file for the given flights and return the file path
  Future<String> generatePdf({
    required List<LogbookEntry> flights,
    required LogbookExportFormat format,
    required String pilotName,
    String? licenseNumber,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Filter flights by date range if specified
    var filteredFlights = flights;
    if (startDate != null || endDate != null) {
      filteredFlights = flights.where((f) {
        if (startDate != null && f.flightDate.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && f.flightDate.isAfter(endDate)) {
          return false;
        }
        return true;
      }).toList();
    }

    // Get the appropriate template
    final template = _getTemplate(format, pilotName, licenseNumber);

    // Generate the PDF document
    final document = template.buildDocument(filteredFlights);

    // Get temporary directory for the file
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final formatName = ExportFormats.getDisplayName(format).toLowerCase().replaceAll(' ', '_');
    final fileName = 'logbook_${formatName}_$timestamp.pdf';
    final filePath = '${directory.path}/$fileName';

    // Save the PDF
    final file = File(filePath);
    await file.writeAsBytes(await document.save());

    return filePath;
  }

  /// Generate PDF and open the share sheet
  Future<void> exportAndShare({
    required List<LogbookEntry> flights,
    required LogbookExportFormat format,
    required String pilotName,
    String? licenseNumber,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final filePath = await generatePdf(
      flights: flights,
      format: format,
      pilotName: pilotName,
      licenseNumber: licenseNumber,
      startDate: startDate,
      endDate: endDate,
    );

    // Share the file
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Pilot Logbook - $pilotName',
    );
  }

  /// Get the appropriate template for the format
  PdfBaseTemplate _getTemplate(
    LogbookExportFormat format,
    String pilotName,
    String? licenseNumber,
  ) {
    switch (format) {
      case LogbookExportFormat.international:
        return InternationalTemplate(
          pilotName: pilotName,
          licenseNumber: licenseNumber,
        );
      case LogbookExportFormat.easa:
        return EasaTemplate(
          pilotName: pilotName,
          licenseNumber: licenseNumber,
        );
      case LogbookExportFormat.faa:
        return FaaTemplate(
          pilotName: pilotName,
          licenseNumber: licenseNumber,
        );
      case LogbookExportFormat.ukCaa:
        return UkCaaTemplate(
          pilotName: pilotName,
          licenseNumber: licenseNumber,
        );
      case LogbookExportFormat.dgac:
        return DgacTemplate(
          pilotName: pilotName,
          licenseNumber: licenseNumber,
        );
    }
  }

  /// Get the count of flights that would be exported
  int getFilteredFlightCount({
    required List<LogbookEntry> flights,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (startDate == null && endDate == null) {
      return flights.length;
    }

    return flights.where((f) {
      if (startDate != null && f.flightDate.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && f.flightDate.isAfter(endDate)) {
        return false;
      }
      return true;
    }).length;
  }
}
