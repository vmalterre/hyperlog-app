import 'package:flutter_test/flutter_test.dart';
import 'package:hyperlog/models/logbook_entry.dart';
import 'package:hyperlog/widgets/trust_badge.dart';

void main() {
  group('FlightTime', () {
    group('constructor', () {
      test('creates with required total', () {
        final ft = FlightTime(total: 120);
        expect(ft.total, 120);
        expect(ft.night, 0);
        expect(ft.ifr, 0);
        expect(ft.pic, 0);
        expect(ft.sic, 0);
        expect(ft.dual, 0);
      });

      test('creates with all optional fields', () {
        final ft = FlightTime(
          total: 180,
          night: 30,
          ifr: 60,
          pic: 90,
          sic: 45,
          dual: 45,
        );
        expect(ft.total, 180);
        expect(ft.night, 30);
        expect(ft.ifr, 60);
        expect(ft.pic, 90);
        expect(ft.sic, 45);
        expect(ft.dual, 45);
      });
    });

    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'total': 240,
          'night': 60,
          'ifr': 120,
          'pic': 180,
          'sic': 30,
          'dual': 30,
        };

        final ft = FlightTime.fromJson(json);

        expect(ft.total, 240);
        expect(ft.night, 60);
        expect(ft.ifr, 120);
        expect(ft.pic, 180);
        expect(ft.sic, 30);
        expect(ft.dual, 30);
      });

      test('defaults missing fields to 0', () {
        final json = {'total': 90};

        final ft = FlightTime.fromJson(json);

        expect(ft.total, 90);
        expect(ft.night, 0);
        expect(ft.ifr, 0);
        expect(ft.pic, 0);
        expect(ft.sic, 0);
        expect(ft.dual, 0);
      });

      test('handles null values as 0', () {
        final json = {
          'total': null,
          'night': null,
        };

        final ft = FlightTime.fromJson(json);

        expect(ft.total, 0);
        expect(ft.night, 0);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final ft = FlightTime(
          total: 120,
          night: 30,
          ifr: 45,
          pic: 60,
          sic: 30,
          dual: 30,
        );

        final json = ft.toJson();

        expect(json['total'], 120);
        expect(json['night'], 30);
        expect(json['ifr'], 45);
        expect(json['pic'], 60);
        expect(json['sic'], 30);
        expect(json['dual'], 30);
      });
    });

    group('formatted', () {
      test('formats 0 minutes as 00:00', () {
        final ft = FlightTime(total: 0);
        expect(ft.formatted, '00:00');
      });

      test('formats minutes only (< 60) correctly', () {
        final ft = FlightTime(total: 45);
        expect(ft.formatted, '00:45');
      });

      test('formats exactly 1 hour correctly', () {
        final ft = FlightTime(total: 60);
        expect(ft.formatted, '01:00');
      });

      test('formats hours and minutes correctly', () {
        final ft = FlightTime(total: 90);
        expect(ft.formatted, '01:30');
      });

      test('formats large values correctly', () {
        final ft = FlightTime(total: 600); // 10 hours
        expect(ft.formatted, '10:00');
      });

      test('pads single digit hours', () {
        final ft = FlightTime(total: 125); // 2:05
        expect(ft.formatted, '02:05');
      });

      test('pads single digit minutes', () {
        final ft = FlightTime(total: 65); // 1:05
        expect(ft.formatted, '01:05');
      });

      test('handles very large flight times', () {
        final ft = FlightTime(total: 1440); // 24 hours
        expect(ft.formatted, '24:00');
      });
    });
  });

  group('Landings', () {
    group('constructor', () {
      test('defaults to 0 for both day and night', () {
        final landings = Landings();
        expect(landings.day, 0);
        expect(landings.night, 0);
      });

      test('accepts day and night values', () {
        final landings = Landings(day: 3, night: 2);
        expect(landings.day, 3);
        expect(landings.night, 2);
      });
    });

    group('fromJson', () {
      test('parses both fields', () {
        final json = {'day': 5, 'night': 3};
        final landings = Landings.fromJson(json);
        expect(landings.day, 5);
        expect(landings.night, 3);
      });

      test('defaults missing fields to 0', () {
        final json = <String, dynamic>{};
        final landings = Landings.fromJson(json);
        expect(landings.day, 0);
        expect(landings.night, 0);
      });

      test('handles null values as 0', () {
        final json = {'day': null, 'night': null};
        final landings = Landings.fromJson(json);
        expect(landings.day, 0);
        expect(landings.night, 0);
      });
    });

    group('toJson', () {
      test('serializes both fields', () {
        final landings = Landings(day: 4, night: 1);
        final json = landings.toJson();
        expect(json['day'], 4);
        expect(json['night'], 1);
      });
    });

    group('total', () {
      test('sums day and night landings', () {
        final landings = Landings(day: 3, night: 2);
        expect(landings.total, 5);
      });

      test('returns 0 when both are 0', () {
        final landings = Landings();
        expect(landings.total, 0);
      });

      test('returns day landings when night is 0', () {
        final landings = Landings(day: 5);
        expect(landings.total, 5);
      });

      test('returns night landings when day is 0', () {
        final landings = Landings(night: 3);
        expect(landings.total, 3);
      });
    });
  });

  group('LogbookEntry', () {
    // Helper to create valid JSON
    Map<String, dynamic> createValidJson({
      String? trustLevel = 'LOGGED',
      String? flightNumber,
      String? remarks,
    }) {
      return {
        'id': 'flight-123',
        'pilotLicense': 'UK-ATPL-12345',
        'flightDate': '2024-06-15T00:00:00.000Z',
        'flightNumber': flightNumber,
        'dep': 'EGLL',
        'dest': 'KJFK',
        'blockOff': '2024-06-15T08:30:00.000Z',
        'blockOn': '2024-06-15T16:00:00.000Z',
        'aircraftType': 'B777',
        'aircraftReg': 'G-VIIA',
        'flightTime': {'total': 450, 'night': 120, 'ifr': 450},
        'landings': {'day': 1, 'night': 0},
        'role': 'PIC',
        'remarks': remarks,
        'trustLevel': trustLevel,
        'createdAt': '2024-06-15T17:00:00.000Z',
        'updatedAt': '2024-06-15T17:00:00.000Z',
      };
    }

    group('fromJson', () {
      test('parses all required fields correctly', () {
        final json = createValidJson();
        final entry = LogbookEntry.fromJson(json);

        expect(entry.id, 'flight-123');
        expect(entry.pilotLicense, 'UK-ATPL-12345');
        expect(entry.flightDate, DateTime.utc(2024, 6, 15));
        expect(entry.dep, 'EGLL');
        expect(entry.dest, 'KJFK');
        expect(entry.blockOff, DateTime.utc(2024, 6, 15, 8, 30));
        expect(entry.blockOn, DateTime.utc(2024, 6, 15, 16, 0));
        expect(entry.aircraftType, 'B777');
        expect(entry.aircraftReg, 'G-VIIA');
        expect(entry.role, 'PIC');
      });

      test('parses nested FlightTime correctly', () {
        final json = createValidJson();
        final entry = LogbookEntry.fromJson(json);

        expect(entry.flightTime.total, 450);
        expect(entry.flightTime.night, 120);
        expect(entry.flightTime.ifr, 450);
      });

      test('parses nested Landings correctly', () {
        final json = createValidJson();
        final entry = LogbookEntry.fromJson(json);

        expect(entry.landings.day, 1);
        expect(entry.landings.night, 0);
        expect(entry.landings.total, 1);
      });

      test('parses optional flightNumber', () {
        final json = createValidJson(flightNumber: 'BA117');
        final entry = LogbookEntry.fromJson(json);
        expect(entry.flightNumber, 'BA117');
      });

      test('parses optional remarks', () {
        final json = createValidJson(remarks: 'Smooth flight');
        final entry = LogbookEntry.fromJson(json);
        expect(entry.remarks, 'Smooth flight');
      });
    });

    group('trust level parsing', () {
      test('parses LOGGED correctly', () {
        final json = createValidJson(trustLevel: 'LOGGED');
        final entry = LogbookEntry.fromJson(json);
        expect(entry.trustLevel, TrustLevel.logged);
      });

      test('parses TRACKED correctly', () {
        final json = createValidJson(trustLevel: 'TRACKED');
        final entry = LogbookEntry.fromJson(json);
        expect(entry.trustLevel, TrustLevel.tracked);
      });

      test('parses ENDORSED correctly', () {
        final json = createValidJson(trustLevel: 'ENDORSED');
        final entry = LogbookEntry.fromJson(json);
        expect(entry.trustLevel, TrustLevel.endorsed);
      });

      test('handles lowercase trust level', () {
        final json = createValidJson(trustLevel: 'tracked');
        final entry = LogbookEntry.fromJson(json);
        expect(entry.trustLevel, TrustLevel.tracked);
      });

      test('handles mixed case trust level', () {
        final json = createValidJson(trustLevel: 'Endorsed');
        final entry = LogbookEntry.fromJson(json);
        expect(entry.trustLevel, TrustLevel.endorsed);
      });

      test('defaults to logged for null trust level', () {
        final json = createValidJson(trustLevel: null);
        final entry = LogbookEntry.fromJson(json);
        expect(entry.trustLevel, TrustLevel.logged);
      });

      test('defaults to logged for unknown trust level', () {
        final json = createValidJson(trustLevel: 'UNKNOWN');
        final entry = LogbookEntry.fromJson(json);
        expect(entry.trustLevel, TrustLevel.logged);
      });
    });

    group('toShort', () {
      test('converts to LogbookEntryShort with correct fields', () {
        final entry = LogbookEntry(
          id: 'flight-456',
          pilotUUID: 'test-uuid-456',
          pilotLicense: 'UK-12345',
          flightDate: DateTime(2024, 7, 20),
          dep: 'EGCC',
          dest: 'LEMD',
          blockOff: DateTime(2024, 7, 20, 6, 0),
          blockOn: DateTime(2024, 7, 20, 8, 30),
          aircraftType: 'A320',
          aircraftReg: 'G-EUPH',
          flightTime: FlightTime(total: 150),
          landings: Landings(day: 1),
          role: 'FO',
          trustLevel: TrustLevel.tracked,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final short = entry.toShort();

        expect(short.id, 'flight-456');
        expect(short.date, DateTime(2024, 7, 20));
        expect(short.depIata, 'EGCC');
        expect(short.desIata, 'LEMD');
        expect(short.acftReg, 'G-EUPH');
        expect(short.acftType, 'A320');
        expect(short.blockTime, '02:30');
        expect(short.trustLevel, TrustLevel.tracked);
      });

      test('formats blockTime correctly from flightTime', () {
        final entry = LogbookEntry(
          id: 'test',
          pilotUUID: 'test-uuid-001',
          pilotLicense: 'UK-12345',
          flightDate: DateTime.now(),
          dep: 'LHR',
          dest: 'JFK',
          blockOff: DateTime.now(),
          blockOn: DateTime.now(),
          aircraftType: 'B747',
          aircraftReg: 'G-CIVX',
          flightTime: FlightTime(total: 480), // 8 hours
          landings: Landings(day: 1),
          role: 'PIC',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final short = entry.toShort();
        expect(short.blockTime, '08:00');
      });
    });

    group('toJson', () {
      test('serializes to correct format for API', () {
        final entry = LogbookEntry(
          id: 'flight-789',
          pilotUUID: 'test-uuid-789',
          pilotLicense: 'UK-ATPL-54321',
          flightDate: DateTime.utc(2024, 8, 1),
          flightNumber: 'VS1',
          dep: 'EGLL',
          dest: 'KJFK',
          blockOff: DateTime.utc(2024, 8, 1, 10, 0),
          blockOn: DateTime.utc(2024, 8, 1, 18, 30),
          aircraftType: 'A350',
          aircraftReg: 'G-VLUX',
          flightTime: FlightTime(total: 510, night: 0, ifr: 510),
          landings: Landings(day: 1, night: 0),
          role: 'PIC',
          remarks: 'Test flight',
          trustLevel: TrustLevel.endorsed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final json = entry.toJson();

        expect(json['pilotLicense'], 'UK-ATPL-54321');
        expect(json['flightDate'], '2024-08-01T00:00:00.000Z');
        expect(json['flightNumber'], 'VS1');
        expect(json['dep'], 'EGLL');
        expect(json['dest'], 'KJFK');
        expect(json['blockOff'], '2024-08-01T10:00:00.000Z');
        expect(json['blockOn'], '2024-08-01T18:30:00.000Z');
        expect(json['aircraftType'], 'A350');
        expect(json['aircraftReg'], 'G-VLUX');
        expect(json['flightTime']['total'], 510);
        expect(json['landings']['day'], 1);
        expect(json['role'], 'PIC');
        expect(json['remarks'], 'Test flight');
      });

      test('handles null optional fields', () {
        final entry = LogbookEntry(
          id: 'test',
          pilotUUID: 'test-uuid-001',
          pilotLicense: 'UK-12345',
          flightDate: DateTime.utc(2024, 1, 1),
          dep: 'EGLL',
          dest: 'LFPG',
          blockOff: DateTime.utc(2024, 1, 1, 8, 0),
          blockOn: DateTime.utc(2024, 1, 1, 9, 0),
          aircraftType: 'A319',
          aircraftReg: 'G-EZAA',
          flightTime: FlightTime(total: 60),
          landings: Landings(day: 1),
          role: 'PIC',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final json = entry.toJson();

        expect(json['flightNumber'], '');
        expect(json['remarks'], '');
      });

      test('does not include id in JSON output', () {
        final entry = LogbookEntry(
          id: 'should-not-appear',
          pilotUUID: 'test-uuid-001',
          pilotLicense: 'UK-12345',
          flightDate: DateTime.utc(2024, 1, 1),
          dep: 'EGLL',
          dest: 'LFPG',
          blockOff: DateTime.utc(2024, 1, 1, 8, 0),
          blockOn: DateTime.utc(2024, 1, 1, 9, 0),
          aircraftType: 'A319',
          aircraftReg: 'G-EZAA',
          flightTime: FlightTime(total: 60),
          landings: Landings(day: 1),
          role: 'PIC',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final json = entry.toJson();
        expect(json.containsKey('id'), false);
      });

      test('does not include trustLevel in JSON output', () {
        final entry = LogbookEntry(
          id: 'test',
          pilotUUID: 'test-uuid-001',
          pilotLicense: 'UK-12345',
          flightDate: DateTime.utc(2024, 1, 1),
          dep: 'EGLL',
          dest: 'LFPG',
          blockOff: DateTime.utc(2024, 1, 1, 8, 0),
          blockOn: DateTime.utc(2024, 1, 1, 9, 0),
          aircraftType: 'A319',
          aircraftReg: 'G-EZAA',
          flightTime: FlightTime(total: 60),
          landings: Landings(day: 1),
          role: 'PIC',
          trustLevel: TrustLevel.endorsed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final json = entry.toJson();
        expect(json.containsKey('trustLevel'), false);
      });
    });

    group('constructor defaults', () {
      test('trustLevel defaults to logged', () {
        final entry = LogbookEntry(
          id: 'test',
          pilotUUID: 'test-uuid-001',
          pilotLicense: 'UK-12345',
          flightDate: DateTime.now(),
          dep: 'LHR',
          dest: 'CDG',
          blockOff: DateTime.now(),
          blockOn: DateTime.now(),
          aircraftType: 'A320',
          aircraftReg: 'G-TEST',
          flightTime: FlightTime(total: 60),
          landings: Landings(),
          role: 'PIC',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(entry.trustLevel, TrustLevel.logged);
      });
    });
  });
}
