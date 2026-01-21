import 'package:flutter_test/flutter_test.dart';
import 'package:hyperlog/models/logbook_entry.dart';
import 'package:hyperlog/pdf/pdf_utils.dart';

void main() {
  group('PageTotals', () {
    group('constructor', () {
      test('creates with default zero values', () {
        final totals = PageTotals();

        expect(totals.totalTime, 0);
        expect(totals.night, 0);
        expect(totals.ifr, 0);
        expect(totals.pic, 0);
        expect(totals.picus, 0);
        expect(totals.sic, 0);
        expect(totals.dual, 0);
        expect(totals.instructor, 0);
        expect(totals.multiEngine, 0);
        expect(totals.crossCountry, 0);
        expect(totals.dayLandings, 0);
        expect(totals.nightLandings, 0);
        expect(totals.dayTakeoffs, 0);
        expect(totals.nightTakeoffs, 0);
      });

      test('creates with custom values', () {
        final totals = PageTotals(
          totalTime: 120,
          night: 30,
          pic: 100,
          dayLandings: 5,
        );

        expect(totals.totalTime, 120);
        expect(totals.night, 30);
        expect(totals.pic, 100);
        expect(totals.dayLandings, 5);
      });
    });

    group('computed properties', () {
      test('totalLandings sums day and night', () {
        final totals = PageTotals(dayLandings: 3, nightLandings: 2);
        expect(totals.totalLandings, 5);
      });

      test('totalTakeoffs sums day and night', () {
        final totals = PageTotals(dayTakeoffs: 4, nightTakeoffs: 1);
        expect(totals.totalTakeoffs, 5);
      });
    });

    group('addEntry', () {
      test('adds flight time fields correctly', () {
        final totals = PageTotals();
        final entry = _createTestEntry(
          totalTime: 90,
          night: 30,
          ifr: 45,
          pic: 90,
          crossCountry: 60,
        );

        totals.addEntry(entry);

        expect(totals.totalTime, 90);
        expect(totals.night, 30);
        expect(totals.ifr, 45);
        expect(totals.pic, 90);
        expect(totals.crossCountry, 60);
      });

      test('accumulates multiple entries', () {
        final totals = PageTotals();

        totals.addEntry(_createTestEntry(totalTime: 60, pic: 60));
        totals.addEntry(_createTestEntry(totalTime: 90, pic: 90));
        totals.addEntry(_createTestEntry(totalTime: 30, pic: 30));

        expect(totals.totalTime, 180);
        expect(totals.pic, 180);
      });
    });

    group('copy', () {
      test('creates independent copy', () {
        final original = PageTotals(
          totalTime: 100,
          night: 20,
          pic: 80,
        );

        final copy = original.copy();

        expect(copy.totalTime, 100);
        expect(copy.night, 20);
        expect(copy.pic, 80);

        // Modify copy, original unchanged
        copy.totalTime = 200;
        expect(original.totalTime, 100);
      });
    });
  });

  group('CumulativeTotals', () {
    test('starts with zero totals', () {
      final cumulative = CumulativeTotals();
      final totals = cumulative.totals;

      expect(totals.totalTime, 0);
      expect(totals.pic, 0);
    });

    test('accumulates page totals', () {
      final cumulative = CumulativeTotals();

      cumulative.addPageTotals(PageTotals(totalTime: 100, pic: 80));
      cumulative.addPageTotals(PageTotals(totalTime: 150, pic: 120));

      final totals = cumulative.totals;
      expect(totals.totalTime, 250);
      expect(totals.pic, 200);
    });

    test('totals getter returns a copy', () {
      final cumulative = CumulativeTotals();
      cumulative.addPageTotals(PageTotals(totalTime: 100));

      final totals1 = cumulative.totals;
      totals1.totalTime = 999;

      final totals2 = cumulative.totals;
      expect(totals2.totalTime, 100);
    });
  });

  group('PdfFormatUtils', () {
    group('formatMinutesAsHHMM', () {
      test('formats zero as empty string', () {
        expect(PdfFormatUtils.formatMinutesAsHHMM(0), '');
      });

      test('formats minutes less than 60', () {
        expect(PdfFormatUtils.formatMinutesAsHHMM(30), '00:30');
        expect(PdfFormatUtils.formatMinutesAsHHMM(45), '00:45');
      });

      test('formats exactly one hour', () {
        expect(PdfFormatUtils.formatMinutesAsHHMM(60), '01:00');
      });

      test('formats hours and minutes', () {
        expect(PdfFormatUtils.formatMinutesAsHHMM(90), '01:30');
        expect(PdfFormatUtils.formatMinutesAsHHMM(135), '02:15');
      });

      test('formats large values', () {
        expect(PdfFormatUtils.formatMinutesAsHHMM(600), '10:00');
        expect(PdfFormatUtils.formatMinutesAsHHMM(1440), '24:00');
      });

      test('pads single digits', () {
        expect(PdfFormatUtils.formatMinutesAsHHMM(5), '00:05');
        expect(PdfFormatUtils.formatMinutesAsHHMM(65), '01:05');
      });
    });

    group('formatMinutesAsDecimal', () {
      test('formats zero as empty string', () {
        expect(PdfFormatUtils.formatMinutesAsDecimal(0), '');
      });

      test('formats minutes as decimal hours', () {
        expect(PdfFormatUtils.formatMinutesAsDecimal(60), '1.0');
        expect(PdfFormatUtils.formatMinutesAsDecimal(90), '1.5');
        expect(PdfFormatUtils.formatMinutesAsDecimal(30), '0.5');
      });

      test('formats to one decimal place', () {
        expect(PdfFormatUtils.formatMinutesAsDecimal(45), '0.8'); // 0.75 rounds to 0.8
        expect(PdfFormatUtils.formatMinutesAsDecimal(75), '1.3'); // 1.25 rounds to 1.3
      });
    });

    group('formatTimeOfDay', () {
      test('formats time correctly', () {
        expect(PdfFormatUtils.formatTimeOfDay(DateTime(2024, 1, 1, 8, 30)), '08:30');
        expect(PdfFormatUtils.formatTimeOfDay(DateTime(2024, 1, 1, 14, 5)), '14:05');
        expect(PdfFormatUtils.formatTimeOfDay(DateTime(2024, 1, 1, 0, 0)), '00:00');
        expect(PdfFormatUtils.formatTimeOfDay(DateTime(2024, 1, 1, 23, 59)), '23:59');
      });

      test('pads single digits', () {
        expect(PdfFormatUtils.formatTimeOfDay(DateTime(2024, 1, 1, 5, 3)), '05:03');
      });
    });

    group('formatDateDDMMYY', () {
      test('formats date correctly', () {
        expect(PdfFormatUtils.formatDateDDMMYY(DateTime(2024, 1, 15)), '15/01/24');
        expect(PdfFormatUtils.formatDateDDMMYY(DateTime(2024, 12, 31)), '31/12/24');
      });

      test('pads single digit day/month', () {
        expect(PdfFormatUtils.formatDateDDMMYY(DateTime(2024, 5, 3)), '03/05/24');
      });
    });

    group('formatDateMMDDYY', () {
      test('formats date in US format', () {
        expect(PdfFormatUtils.formatDateMMDDYY(DateTime(2024, 1, 15)), '01/15/24');
        expect(PdfFormatUtils.formatDateMMDDYY(DateTime(2024, 12, 31)), '12/31/24');
      });
    });

    group('formatDateDDMMYYYY', () {
      test('formats date with full year', () {
        expect(PdfFormatUtils.formatDateDDMMYYYY(DateTime(2024, 1, 15)), '15-01-2024');
        expect(PdfFormatUtils.formatDateDDMMYYYY(DateTime(2024, 12, 31)), '31-12-2024');
      });
    });

    group('formatDateISO', () {
      test('formats date in ISO format', () {
        expect(PdfFormatUtils.formatDateISO(DateTime(2024, 1, 15)), '2024-01-15');
        expect(PdfFormatUtils.formatDateISO(DateTime(2024, 12, 31)), '2024-12-31');
      });

      test('pads single digit day/month', () {
        expect(PdfFormatUtils.formatDateISO(DateTime(2024, 5, 3)), '2024-05-03');
      });
    });

    group('formatInt', () {
      test('returns empty string for zero', () {
        expect(PdfFormatUtils.formatInt(0), '');
      });

      test('returns string for non-zero', () {
        expect(PdfFormatUtils.formatInt(1), '1');
        expect(PdfFormatUtils.formatInt(42), '42');
        expect(PdfFormatUtils.formatInt(100), '100');
      });
    });

    group('getPicName', () {
      test('returns dash for empty crew', () {
        final entry = _createTestEntryWithCrew([], creatorUUID: 'no-crew');
        expect(PdfFormatUtils.getPicName(entry), '—');
      });

      test('returns creator name if creator is PIC', () {
        final entry = _createTestEntryWithCrew([
          _createCrewMember('user-1', 'John Smith', 'PIC'),
        ], creatorUUID: 'user-1');

        expect(PdfFormatUtils.getPicName(entry), 'John Smith');
      });

      test('returns other PIC name if creator is not PIC', () {
        final entry = _createTestEntryWithCrew([
          _createCrewMember('user-1', 'Co-Pilot', 'SIC'),
          _createCrewMember('user-2', 'Captain', 'PIC'),
        ], creatorUUID: 'user-1');

        expect(PdfFormatUtils.getPicName(entry), 'Captain');
      });

      test('returns dash if no PIC in crew', () {
        final entry = _createTestEntryWithCrew([
          _createCrewMember('user-1', 'Pilot 1', 'SIC'),
          _createCrewMember('user-2', 'Pilot 2', 'DUAL'),
        ], creatorUUID: 'user-1');

        expect(PdfFormatUtils.getPicName(entry), '—');
      });
    });

    group('getRemarks', () {
      test('returns empty string for no remarks', () {
        final entry = _createTestEntryWithCrew([
          _createCrewMember('user-1', 'Pilot', 'PIC', remarks: ''),
        ], creatorUUID: 'user-1');

        expect(PdfFormatUtils.getRemarks(entry), '');
      });

      test('returns creator remarks', () {
        final entry = _createTestEntryWithCrew([
          _createCrewMember('user-1', 'Pilot', 'PIC', remarks: 'Training flight'),
        ], creatorUUID: 'user-1');

        expect(PdfFormatUtils.getRemarks(entry), 'Training flight');
      });
    });
  });
}

/// Helper to create a minimal test LogbookEntry
LogbookEntry _createTestEntry({
  int totalTime = 60,
  int night = 0,
  int ifr = 0,
  int pic = 0,
  int sic = 0,
  int dual = 0,
  int instructor = 0,
  int multiEngine = 0,
  int crossCountry = 0,
}) {
  final now = DateTime.now();
  return LogbookEntry(
    id: 'test-entry',
    creatorUUID: 'test-user',
    flightDate: now,
    dep: 'EGLL',
    dest: 'KJFK',
    blockOff: now,
    blockOn: now.add(Duration(minutes: totalTime)),
    aircraftType: 'A320',
    aircraftReg: 'G-TEST',
    flightTime: FlightTime(
      total: totalTime,
      night: night,
      ifr: ifr,
      pic: pic,
      sic: sic,
      dual: dual,
      instructor: instructor,
      multiEngine: multiEngine,
      crossCountry: crossCountry,
    ),
    crew: [
      CrewMember(
        pilotUUID: 'test-user',
        pilotName: 'Test Pilot',
        roles: [
          RoleSegment(
            role: 'PIC',
            start: now,
            end: now.add(Duration(minutes: totalTime)),
          ),
        ],
        landings: const Landings(day: 1),
        takeoffs: const Takeoffs(day: 1),
        joinedAt: now,
      ),
    ],
    createdAt: now,
    updatedAt: now,
  );
}

/// Helper to create a test entry with specific crew
LogbookEntry _createTestEntryWithCrew(
  List<CrewMember> crew, {
  required String creatorUUID,
}) {
  final now = DateTime.now();
  return LogbookEntry(
    id: 'test-entry',
    creatorUUID: creatorUUID,
    flightDate: now,
    dep: 'EGLL',
    dest: 'KJFK',
    blockOff: now,
    blockOn: now.add(const Duration(hours: 1)),
    aircraftType: 'A320',
    aircraftReg: 'G-TEST',
    flightTime: FlightTime(total: 60),
    crew: crew,
    createdAt: now,
    updatedAt: now,
  );
}

/// Helper to create a crew member
CrewMember _createCrewMember(
  String uuid,
  String name,
  String role, {
  String remarks = '',
}) {
  final now = DateTime.now();
  return CrewMember(
    pilotUUID: uuid,
    pilotName: name,
    roles: [
      RoleSegment(
        role: role,
        start: now,
        end: now.add(const Duration(hours: 1)),
      ),
    ],
    landings: const Landings(day: 1),
    remarks: remarks,
    joinedAt: now,
  );
}
