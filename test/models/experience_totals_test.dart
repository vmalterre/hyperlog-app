import 'package:flutter_test/flutter_test.dart';
import 'package:hyperlog/models/experience_totals.dart';
import 'package:hyperlog/models/logbook_entry.dart';

void main() {
  group('ExperienceTotals', () {
    group('fromFlights', () {
      // Helper to create a LogbookEntry with specific time values
      LogbookEntry createFlight({
        int total = 60,
        int night = 0,
        int ifr = 0,
        int pic = 0,
        int sic = 0,
        int dual = 0,
        int picus = 0,
        int landingsDay = 0,
        int landingsNight = 0,
        String aircraftType = 'C172',
        String? simReg,
      }) {
        return LogbookEntry(
          id: 'flight-${DateTime.now().millisecondsSinceEpoch}',
          creatorUUID: 'pilot-uuid',
          flightDate: DateTime.now(),
          dep: 'EGLL',
          dest: 'KJFK',
          blockOff: DateTime.now(),
          blockOn: DateTime.now().add(Duration(minutes: total)),
          aircraftType: aircraftType,
          aircraftReg: simReg != null ? null : 'G-TEST',
          simReg: simReg,
          flightTime: FlightTime(
            total: total,
            night: night,
            ifr: ifr,
            pic: pic,
            sic: sic,
            dual: dual,
            picus: picus,
          ),
          landingsDay: landingsDay,
          landingsNight: landingsNight,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      test('returns empty totals for empty flight list', () {
        final totals = ExperienceTotals.fromFlights([]);

        expect(totals.totalMinutes, 0);
        expect(totals.picMinutes, 0);
        expect(totals.sicMinutes, 0);
        expect(totals.dualMinutes, 0);
        expect(totals.nightMinutes, 0);
        expect(totals.ifrMinutes, 0);
        expect(totals.dayLandings, 0);
        expect(totals.nightLandings, 0);
      });

      test('sums total time from flights only (excludes sim sessions)', () {
        final flights = [
          createFlight(total: 60),
          createFlight(total: 90),
          createFlight(total: 120),
          createFlight(total: 30, simReg: 'FNPT-II'), // sim session
        ];

        final totals = ExperienceTotals.fromFlights(flights);

        expect(totals.totalMinutes, 270); // 60 + 90 + 120 (sim excluded)
      });

      test('sim sessions counted in simulatorMinutes', () {
        final flights = [
          createFlight(total: 60),
          createFlight(total: 120, simReg: 'FNPT-II'),
          createFlight(total: 90, simReg: 'FFS-A320'),
        ];

        final totals = ExperienceTotals.fromFlights(flights);

        expect(totals.simulatorMinutes, 210); // 120 + 90
        expect(totals.totalMinutes, 60); // only the real flight
      });

      test('sums PICUS time correctly', () {
        final flights = [
          createFlight(total: 480, picus: 480),
          createFlight(total: 540, picus: 540),
          createFlight(total: 60, picus: 0),
        ];

        final totals = ExperienceTotals.fromFlights(flights);

        expect(totals.picusMinutes, 1020); // 480 + 540
      });

      test('sums PIC time from flightTime.pic field', () {
        final flights = [
          createFlight(total: 60, pic: 60),
          createFlight(total: 90, pic: 90),
          createFlight(total: 120, pic: 0), // No PIC time on this flight
        ];

        final totals = ExperienceTotals.fromFlights(flights);

        expect(totals.picMinutes, 150); // 60 + 90 + 0
      });

      test('sums SIC time from flightTime.sic field', () {
        final flights = [
          createFlight(total: 480, sic: 480),
          createFlight(total: 540, sic: 540),
        ];

        final totals = ExperienceTotals.fromFlights(flights);

        expect(totals.sicMinutes, 1020); // 480 + 540
      });

      test('sums DUAL time from flightTime.dual field', () {
        final flights = [
          createFlight(total: 60, dual: 60),
          createFlight(total: 90, dual: 90),
          createFlight(total: 45, dual: 45),
        ];

        final totals = ExperienceTotals.fromFlights(flights);

        expect(totals.dualMinutes, 195); // 60 + 90 + 45
      });

      test('sums night time correctly', () {
        final flights = [
          createFlight(total: 60, night: 30),
          createFlight(total: 90, night: 60),
        ];

        final totals = ExperienceTotals.fromFlights(flights);

        expect(totals.nightMinutes, 90); // 30 + 60
      });

      test('sums IFR time correctly', () {
        final flights = [
          createFlight(total: 60, ifr: 45),
          createFlight(total: 90, ifr: 90),
        ];

        final totals = ExperienceTotals.fromFlights(flights);

        expect(totals.ifrMinutes, 135); // 45 + 90
      });

      test('sums day landings from direct fields', () {
        final flights = [
          createFlight(landingsDay: 1),
          createFlight(landingsDay: 2),
          createFlight(landingsDay: 3),
        ];

        final totals = ExperienceTotals.fromFlights(flights);

        expect(totals.dayLandings, 6); // 1 + 2 + 3
      });

      test('sums night landings from direct fields', () {
        final flights = [
          createFlight(landingsNight: 1),
          createFlight(landingsNight: 2),
        ];

        final totals = ExperienceTotals.fromFlights(flights);

        expect(totals.nightLandings, 3); // 1 + 2
      });

      test('handles mixed PIC, SIC, and DUAL flights', () {
        final flights = [
          createFlight(total: 60, pic: 60, sic: 0, dual: 0),
          createFlight(total: 120, pic: 0, sic: 120, dual: 0),
          createFlight(total: 45, pic: 0, sic: 0, dual: 45),
        ];

        final totals = ExperienceTotals.fromFlights(flights);

        expect(totals.totalMinutes, 225);
        expect(totals.picMinutes, 60);
        expect(totals.sicMinutes, 120);
        expect(totals.dualMinutes, 45);
      });

      test('calculates totalLandings as sum of day and night', () {
        final flights = [
          createFlight(landingsDay: 2, landingsNight: 1),
          createFlight(landingsDay: 3, landingsNight: 2),
        ];

        final totals = ExperienceTotals.fromFlights(flights);

        expect(totals.dayLandings, 5);
        expect(totals.nightLandings, 3);
        expect(totals.totalLandings, 8); // 5 + 3
      });

      test('categorizes jet aircraft time correctly', () {
        final flights = [
          createFlight(total: 480, aircraftType: 'B738'), // Boeing 737-800
          createFlight(total: 540, aircraftType: 'A320'), // Airbus A320
          createFlight(total: 60, aircraftType: 'C172'),  // Cessna (not jet)
        ];

        final totals = ExperienceTotals.fromFlights(flights);

        expect(totals.jetMinutes, 1020); // 480 + 540
      });

      test('categorizes GA/piston aircraft time correctly', () {
        final flights = [
          createFlight(total: 60, aircraftType: 'C172'),  // Cessna 172
          createFlight(total: 90, aircraftType: 'PA28'),  // Piper Cherokee
          createFlight(total: 480, aircraftType: 'B738'), // Boeing (not piston)
        ];

        final totals = ExperienceTotals.fromFlights(flights);

        expect(totals.gaPistonMinutes, 150); // 60 + 90
      });
    });

    group('formatMinutes', () {
      test('formats 0 minutes as 0:00', () {
        expect(ExperienceTotals.formatMinutes(0), '0:00');
      });

      test('formats minutes less than 60 correctly', () {
        expect(ExperienceTotals.formatMinutes(45), '0:45');
      });

      test('formats exactly 60 minutes as 1:00', () {
        expect(ExperienceTotals.formatMinutes(60), '1:00');
      });

      test('formats hours and minutes correctly', () {
        expect(ExperienceTotals.formatMinutes(90), '1:30');
        expect(ExperienceTotals.formatMinutes(125), '2:05');
      });

      test('formats large values correctly', () {
        expect(ExperienceTotals.formatMinutes(600), '10:00');
        expect(ExperienceTotals.formatMinutes(1440), '24:00');
      });

      test('pads single digit minutes', () {
        expect(ExperienceTotals.formatMinutes(65), '1:05');
        expect(ExperienceTotals.formatMinutes(601), '10:01');
      });
    });

    group('formatted getters', () {
      test('totalFormatted returns formatted total time', () {
        final totals = ExperienceTotals(
          totalMinutes: 150,
          picMinutes: 0,
          sicMinutes: 0,
          dualMinutes: 0,
          nightMinutes: 0,
          ifrMinutes: 0,
          dayLandings: 0,
          nightLandings: 0,
          jetMinutes: 0,
          gaPistonMinutes: 0,
          simulatorMinutes: 0,
          picusMinutes: 0,
        );

        expect(totals.totalFormatted, '2:30');
      });

      test('picFormatted returns formatted PIC time', () {
        final totals = ExperienceTotals(
          totalMinutes: 0,
          picMinutes: 7650,
          sicMinutes: 0,
          dualMinutes: 0,
          nightMinutes: 0,
          ifrMinutes: 0,
          dayLandings: 0,
          nightLandings: 0,
          jetMinutes: 0,
          gaPistonMinutes: 0,
          simulatorMinutes: 0,
          picusMinutes: 0,
        );

        expect(totals.picFormatted, '127:30'); // 7650 / 60 = 127.5
      });
    });
  });

  group('LogbookEntry.totalLandings', () {
    test('uses direct fields when landingsDay > 0', () {
      final entry = LogbookEntry(
        id: 'test',
        creatorUUID: 'pilot',
        flightDate: DateTime.now(),
        dep: 'EGLL',
        dest: 'KJFK',
        blockOff: DateTime.now(),
        blockOn: DateTime.now(),
        aircraftType: 'A320',
        flightTime: FlightTime(total: 60),
        landingsDay: 2,
        landingsNight: 1,
        crew: [], // Empty crew
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(entry.totalLandings.day, 2);
      expect(entry.totalLandings.night, 1);
    });

    test('uses direct fields when landingsNight > 0', () {
      final entry = LogbookEntry(
        id: 'test',
        creatorUUID: 'pilot',
        flightDate: DateTime.now(),
        dep: 'EGLL',
        dest: 'KJFK',
        blockOff: DateTime.now(),
        blockOn: DateTime.now(),
        aircraftType: 'A320',
        flightTime: FlightTime(total: 60),
        landingsDay: 0,
        landingsNight: 3,
        crew: [], // Empty crew
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(entry.totalLandings.day, 0);
      expect(entry.totalLandings.night, 3);
    });

    test('falls back to crew landings when direct fields are 0', () {
      final entry = LogbookEntry(
        id: 'test',
        creatorUUID: 'pilot-uuid',
        flightDate: DateTime.now(),
        dep: 'EGLL',
        dest: 'KJFK',
        blockOff: DateTime.now(),
        blockOn: DateTime.now(),
        aircraftType: 'A320',
        flightTime: FlightTime(total: 60),
        landingsDay: 0,
        landingsNight: 0,
        crew: [
          CrewMember(
            pilotUUID: 'pilot-uuid',
            roles: [],
            landings: Landings(day: 1, night: 0),
            joinedAt: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(entry.totalLandings.day, 1);
      expect(entry.totalLandings.night, 0);
    });
  });
}
