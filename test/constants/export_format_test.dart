import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:hyperlog/constants/export_format.dart';

void main() {
  group('LogbookExportFormat', () {
    test('has five values', () {
      expect(LogbookExportFormat.values.length, 5);
      expect(LogbookExportFormat.values, contains(LogbookExportFormat.international));
      expect(LogbookExportFormat.values, contains(LogbookExportFormat.easa));
      expect(LogbookExportFormat.values, contains(LogbookExportFormat.faa));
      expect(LogbookExportFormat.values, contains(LogbookExportFormat.ukCaa));
      expect(LogbookExportFormat.values, contains(LogbookExportFormat.dgac));
    });
  });

  group('ExportFormatInfo', () {
    test('stores all properties', () {
      const info = ExportFormatInfo(
        displayName: 'Test Format',
        description: 'A test format',
        pageFormat: PdfPageFormat.a4,
        rowsPerPage: 20,
        isTwoPageSpread: true,
      );

      expect(info.displayName, 'Test Format');
      expect(info.description, 'A test format');
      expect(info.pageFormat, PdfPageFormat.a4);
      expect(info.rowsPerPage, 20);
      expect(info.isTwoPageSpread, true);
    });

    test('isTwoPageSpread defaults to false', () {
      const info = ExportFormatInfo(
        displayName: 'Test',
        description: 'Test',
        pageFormat: PdfPageFormat.a4,
        rowsPerPage: 10,
      );

      expect(info.isTwoPageSpread, false);
    });
  });

  group('ExportFormats', () {
    group('getDisplayName', () {
      test('returns correct name for International', () {
        expect(ExportFormats.getDisplayName(LogbookExportFormat.international), 'International');
      });

      test('returns correct name for EASA', () {
        expect(ExportFormats.getDisplayName(LogbookExportFormat.easa), 'EASA');
      });

      test('returns correct name for FAA', () {
        expect(ExportFormats.getDisplayName(LogbookExportFormat.faa), 'FAA');
      });

      test('returns correct name for UK CAA', () {
        expect(ExportFormats.getDisplayName(LogbookExportFormat.ukCaa), 'UK CAA');
      });

      test('returns correct name for French DGAC', () {
        expect(ExportFormats.getDisplayName(LogbookExportFormat.dgac), 'French DGAC');
      });
    });

    group('getDescription', () {
      test('returns non-empty description for all formats', () {
        for (final format in LogbookExportFormat.values) {
          final description = ExportFormats.getDescription(format);
          expect(description, isNotEmpty, reason: '${format.name} should have a description');
        }
      });

      test('International mentions universal/Coradine', () {
        final desc = ExportFormats.getDescription(LogbookExportFormat.international);
        expect(desc.toLowerCase(), anyOf(contains('universal'), contains('coradine')));
      });

      test('EASA mentions European', () {
        final desc = ExportFormats.getDescription(LogbookExportFormat.easa);
        expect(desc.toLowerCase(), contains('european'));
      });

      test('FAA mentions US/Jeppesen', () {
        final desc = ExportFormats.getDescription(LogbookExportFormat.faa);
        expect(desc.toLowerCase(), anyOf(contains('us'), contains('jeppesen')));
      });

      test('UK CAA mentions UK', () {
        final desc = ExportFormats.getDescription(LogbookExportFormat.ukCaa);
        expect(desc.toLowerCase(), contains('uk'));
      });

      test('DGAC mentions French/bilingual', () {
        final desc = ExportFormats.getDescription(LogbookExportFormat.dgac);
        expect(desc.toLowerCase(), anyOf(contains('french'), contains('bilingual')));
      });
    });

    group('getInfo', () {
      test('International uses A4, 20 rows, single page', () {
        final info = ExportFormats.getInfo(LogbookExportFormat.international);
        expect(info.pageFormat, PdfPageFormat.a4);
        expect(info.rowsPerPage, 20);
        expect(info.isTwoPageSpread, false);
      });

      test('EASA uses A4, 16 rows, two-page spread', () {
        final info = ExportFormats.getInfo(LogbookExportFormat.easa);
        expect(info.pageFormat, PdfPageFormat.a4);
        expect(info.rowsPerPage, 16);
        expect(info.isTwoPageSpread, true);
      });

      test('FAA uses Letter, 27 rows, two-page spread', () {
        final info = ExportFormats.getInfo(LogbookExportFormat.faa);
        expect(info.pageFormat, PdfPageFormat.letter);
        expect(info.rowsPerPage, 27);
        expect(info.isTwoPageSpread, true);
      });

      test('UK CAA uses A4, 18 rows, two-page spread', () {
        final info = ExportFormats.getInfo(LogbookExportFormat.ukCaa);
        expect(info.pageFormat, PdfPageFormat.a4);
        expect(info.rowsPerPage, 18);
        expect(info.isTwoPageSpread, true);
      });

      test('DGAC uses A5, 12 rows, single page', () {
        final info = ExportFormats.getInfo(LogbookExportFormat.dgac);
        expect(info.pageFormat, PdfPageFormat.a5);
        expect(info.rowsPerPage, 12);
        expect(info.isTwoPageSpread, false);
      });
    });

    group('allFormats', () {
      test('returns all format values', () {
        expect(ExportFormats.allFormats, LogbookExportFormat.values);
      });

      test('returns 5 formats', () {
        expect(ExportFormats.allFormats.length, 5);
      });
    });
  });
}
