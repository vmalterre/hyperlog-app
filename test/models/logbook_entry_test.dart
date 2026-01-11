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
      });

      test('creates with all optional fields', () {
        final ft = FlightTime(
          total: 180,
          night: 30,
          ifr: 60,
        );
        expect(ft.total, 180);
        expect(ft.night, 30);
        expect(ft.ifr, 60);
      });
    });

    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'total': 240,
          'night': 60,
          'ifr': 120,
        };

        final ft = FlightTime.fromJson(json);

        expect(ft.total, 240);
        expect(ft.night, 60);
        expect(ft.ifr, 120);
      });

      test('defaults missing fields to 0', () {
        final json = {'total': 90};

        final ft = FlightTime.fromJson(json);

        expect(ft.total, 90);
        expect(ft.night, 0);
        expect(ft.ifr, 0);
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
        );

        final json = ft.toJson();

        expect(json['total'], 120);
        expect(json['night'], 30);
        expect(json['ifr'], 45);
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

  group('RoleSegment', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'role': 'PIC',
          'start': '2024-06-15T08:30:00.000Z',
          'end': '2024-06-15T16:00:00.000Z',
        };

        final segment = RoleSegment.fromJson(json);

        expect(segment.role, 'PIC');
        expect(segment.start, DateTime.utc(2024, 6, 15, 8, 30));
        expect(segment.end, DateTime.utc(2024, 6, 15, 16, 0));
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final segment = RoleSegment(
          role: 'SIC',
          start: DateTime.utc(2024, 6, 15, 8, 30),
          end: DateTime.utc(2024, 6, 15, 12, 0),
        );

        final json = segment.toJson();

        expect(json['role'], 'SIC');
        expect(json['start'], '2024-06-15T08:30:00.000Z');
        expect(json['end'], '2024-06-15T12:00:00.000Z');
      });
    });

    group('durationMinutes', () {
      test('calculates duration correctly', () {
        final segment = RoleSegment(
          role: 'PIC',
          start: DateTime.utc(2024, 6, 15, 8, 0),
          end: DateTime.utc(2024, 6, 15, 10, 30),
        );

        expect(segment.durationMinutes, 150); // 2.5 hours
      });

      test('returns 0 for same start and end', () {
        final now = DateTime.utc(2024, 6, 15, 8, 0);
        final segment = RoleSegment(
          role: 'PIC',
          start: now,
          end: now,
        );

        expect(segment.durationMinutes, 0);
      });
    });
  });

  group('CrewMember', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'pilotUUID': 'uuid-123',
          'pilotLicense': 'UK-ATPL-12345',
          'pilotName': 'John Doe',
          'roles': [
            {
              'role': 'PIC',
              'start': '2024-06-15T08:30:00.000Z',
              'end': '2024-06-15T16:00:00.000Z',
            }
          ],
          'landings': {'day': 1, 'night': 0},
          'remarks': 'Good flight',
          'joinedAt': '2024-06-15T08:30:00.000Z',
        };

        final crew = CrewMember.fromJson(json);

        expect(crew.pilotUUID, 'uuid-123');
        expect(crew.pilotLicense, 'UK-ATPL-12345');
        expect(crew.pilotName, 'John Doe');
        expect(crew.roles.length, 1);
        expect(crew.roles[0].role, 'PIC');
        expect(crew.landings.day, 1);
        expect(crew.remarks, 'Good flight');
      });

      test('defaults empty roles and landings', () {
        final json = {
          'pilotUUID': 'uuid-456',
          'joinedAt': '2024-06-15T08:30:00.000Z',
        };

        final crew = CrewMember.fromJson(json);

        expect(crew.roles, isEmpty);
        expect(crew.landings.day, 0);
        expect(crew.landings.night, 0);
        expect(crew.remarks, '');
      });
    });

    group('primaryRole', () {
      test('returns empty string when no roles', () {
        final crew = CrewMember(
          pilotUUID: 'uuid-123',
          roles: [],
          landings: Landings(),
          joinedAt: DateTime.now(),
        );

        expect(crew.primaryRole, '');
      });

      test('returns single role when only one', () {
        final crew = CrewMember(
          pilotUUID: 'uuid-123',
          roles: [
            RoleSegment(
              role: 'PIC',
              start: DateTime.utc(2024, 6, 15, 8, 0),
              end: DateTime.utc(2024, 6, 15, 16, 0),
            ),
          ],
          landings: Landings(day: 1),
          joinedAt: DateTime.now(),
        );

        expect(crew.primaryRole, 'PIC');
      });

      test('returns longest duration role', () {
        final crew = CrewMember(
          pilotUUID: 'uuid-123',
          roles: [
            RoleSegment(
              role: 'PIC',
              start: DateTime.utc(2024, 6, 15, 8, 0),
              end: DateTime.utc(2024, 6, 15, 10, 0), // 2 hours
            ),
            RoleSegment(
              role: 'SIC',
              start: DateTime.utc(2024, 6, 15, 10, 0),
              end: DateTime.utc(2024, 6, 15, 16, 0), // 6 hours
            ),
          ],
          landings: Landings(),
          joinedAt: DateTime.now(),
        );

        expect(crew.primaryRole, 'SIC');
      });
    });

    group('roleTimeMinutes', () {
      test('calculates total time for a role', () {
        final crew = CrewMember(
          pilotUUID: 'uuid-123',
          roles: [
            RoleSegment(
              role: 'PIC',
              start: DateTime.utc(2024, 6, 15, 8, 0),
              end: DateTime.utc(2024, 6, 15, 10, 0), // 2 hours = 120 min
            ),
            RoleSegment(
              role: 'SIC',
              start: DateTime.utc(2024, 6, 15, 10, 0),
              end: DateTime.utc(2024, 6, 15, 12, 0), // 2 hours = 120 min
            ),
            RoleSegment(
              role: 'PIC',
              start: DateTime.utc(2024, 6, 15, 12, 0),
              end: DateTime.utc(2024, 6, 15, 14, 0), // 2 hours = 120 min
            ),
          ],
          landings: Landings(),
          joinedAt: DateTime.now(),
        );

        expect(crew.roleTimeMinutes('PIC'), 240); // 4 hours total
        expect(crew.roleTimeMinutes('SIC'), 120); // 2 hours
        expect(crew.roleTimeMinutes('DUAL'), 0); // None
      });
    });
  });

  group('LogbookEntry', () {
    // Helper to create valid JSON
    Map<String, dynamic> createValidJson({
      int crewCount = 1,
      int verificationCount = 0,
    }) {
      final crew = List.generate(crewCount, (i) => {
        'pilotUUID': 'uuid-$i',
        'pilotLicense': 'UK-ATPL-$i',
        'roles': [
          {
            'role': i == 0 ? 'PIC' : 'SIC',
            'start': '2024-06-15T08:30:00.000Z',
            'end': '2024-06-15T16:00:00.000Z',
          }
        ],
        'landings': {'day': i == 0 ? 1 : 0, 'night': 0},
        'remarks': '',
        'joinedAt': '2024-06-15T08:30:00.000Z',
      });

      final verifications = List.generate(verificationCount, (i) => {
        'source': 'FlightRadar24',
        'verifiedAt': '2024-06-15T17:00:00.000Z',
        'verifiedBy': 'HyperLog Trust Engine',
        'matchData': 'FR24-$i',
      });

      return {
        'id': 'flight-123',
        'creatorUUID': 'uuid-0',
        'creatorLicense': 'UK-ATPL-0',
        'flightDate': '2024-06-15',
        'flightNumber': 'BA117',
        'dep': 'EGLL',
        'dest': 'KJFK',
        'blockOff': '2024-06-15T08:30:00.000Z',
        'blockOn': '2024-06-15T16:00:00.000Z',
        'aircraftType': 'B777',
        'aircraftReg': 'G-VIIA',
        'flightTime': {'total': 450, 'night': 120, 'ifr': 450},
        'crew': crew,
        'verifications': verifications,
        'endorsements': [],
        'createdAt': '2024-06-15T17:00:00.000Z',
        'updatedAt': '2024-06-15T17:00:00.000Z',
      };
    }

    group('fromJson', () {
      test('parses all required fields correctly', () {
        final json = createValidJson();
        final entry = LogbookEntry.fromJson(json);

        expect(entry.id, 'flight-123');
        expect(entry.creatorUUID, 'uuid-0');
        expect(entry.creatorLicense, 'UK-ATPL-0');
        expect(entry.flightDate, DateTime.utc(2024, 6, 15));
        expect(entry.flightNumber, 'BA117');
        expect(entry.dep, 'EGLL');
        expect(entry.dest, 'KJFK');
        expect(entry.blockOff, DateTime.utc(2024, 6, 15, 8, 30));
        expect(entry.blockOn, DateTime.utc(2024, 6, 15, 16, 0));
        expect(entry.aircraftType, 'B777');
        expect(entry.aircraftReg, 'G-VIIA');
      });

      test('parses nested FlightTime correctly', () {
        final json = createValidJson();
        final entry = LogbookEntry.fromJson(json);

        expect(entry.flightTime.total, 450);
        expect(entry.flightTime.night, 120);
        expect(entry.flightTime.ifr, 450);
      });

      test('parses crew array correctly', () {
        final json = createValidJson(crewCount: 2);
        final entry = LogbookEntry.fromJson(json);

        expect(entry.crew.length, 2);
        expect(entry.crew[0].pilotUUID, 'uuid-0');
        expect(entry.crew[0].roles[0].role, 'PIC');
        expect(entry.crew[1].pilotUUID, 'uuid-1');
        expect(entry.crew[1].roles[0].role, 'SIC');
      });

      test('defaults empty arrays when missing', () {
        final json = createValidJson();
        json.remove('crew');
        json.remove('verifications');
        json.remove('endorsements');

        final entry = LogbookEntry.fromJson(json);

        expect(entry.crew, isEmpty);
        expect(entry.verifications, isEmpty);
        expect(entry.endorsements, isEmpty);
      });
    });

    group('trustLevel (computed)', () {
      test('returns LOGGED for single crew no verifications', () {
        final json = createValidJson(crewCount: 1, verificationCount: 0);
        final entry = LogbookEntry.fromJson(json);
        expect(entry.trustLevel, TrustLevel.logged);
      });

      test('returns TRACKED when verifications exist', () {
        final json = createValidJson(crewCount: 1, verificationCount: 1);
        final entry = LogbookEntry.fromJson(json);
        expect(entry.trustLevel, TrustLevel.tracked);
      });

      test('returns ENDORSED when 2+ crew members', () {
        final json = createValidJson(crewCount: 2, verificationCount: 0);
        final entry = LogbookEntry.fromJson(json);
        expect(entry.trustLevel, TrustLevel.endorsed);
      });

      test('ENDORSED takes priority over TRACKED', () {
        final json = createValidJson(crewCount: 2, verificationCount: 1);
        final entry = LogbookEntry.fromJson(json);
        expect(entry.trustLevel, TrustLevel.endorsed);
      });

      test('returns LOGGED for empty crew', () {
        final json = createValidJson(crewCount: 0, verificationCount: 0);
        final entry = LogbookEntry.fromJson(json);
        expect(entry.trustLevel, TrustLevel.logged);
      });
    });

    group('creatorCrew', () {
      test('returns crew member matching creatorUUID', () {
        final json = createValidJson(crewCount: 2);
        final entry = LogbookEntry.fromJson(json);

        expect(entry.creatorCrew?.pilotUUID, 'uuid-0');
        expect(entry.creatorCrew?.roles[0].role, 'PIC');
      });

      test('returns null for empty crew', () {
        final json = createValidJson(crewCount: 0);
        final entry = LogbookEntry.fromJson(json);

        expect(entry.creatorCrew, isNull);
      });
    });

    group('totalLandings', () {
      test('sums landings from all crew members', () {
        final json = createValidJson(crewCount: 2);
        // First crew has day: 1, second has day: 0
        final entry = LogbookEntry.fromJson(json);

        expect(entry.totalLandings.day, 1);
        expect(entry.totalLandings.night, 0);
      });

      test('returns zero for empty crew', () {
        final json = createValidJson(crewCount: 0);
        final entry = LogbookEntry.fromJson(json);

        expect(entry.totalLandings.day, 0);
        expect(entry.totalLandings.night, 0);
      });
    });

    group('toShort', () {
      test('converts to LogbookEntryShort with correct fields', () {
        final json = createValidJson(crewCount: 1);
        final entry = LogbookEntry.fromJson(json);

        final short = entry.toShort();

        expect(short.id, 'flight-123');
        expect(short.date, DateTime.utc(2024, 6, 15));
        expect(short.depIata, 'EGLL');
        expect(short.desIata, 'KJFK');
        expect(short.acftReg, 'G-VIIA');
        expect(short.acftType, 'B777');
        expect(short.blockTime, '07:30'); // 450 min
        expect(short.trustLevel, TrustLevel.logged);
      });

      test('includes computed trustLevel', () {
        final json = createValidJson(crewCount: 2);
        final entry = LogbookEntry.fromJson(json);

        final short = entry.toShort();
        expect(short.trustLevel, TrustLevel.endorsed);
      });
    });

    group('toJson', () {
      test('serializes to CreateFlightRequest format', () {
        final json = createValidJson(crewCount: 1);
        final entry = LogbookEntry.fromJson(json);

        final output = entry.toJson();

        expect(output['pilotLicense'], 'UK-ATPL-0');
        expect(output['flightDate'], '2024-06-15');
        expect(output['flightNumber'], 'BA117');
        expect(output['dep'], 'EGLL');
        expect(output['dest'], 'KJFK');
        expect(output['aircraftType'], 'B777');
        expect(output['aircraftReg'], 'G-VIIA');
        expect(output['flightTime']['total'], 450);
        expect(output['roles'], isA<List>());
        expect(output['landings']['day'], 1);
      });

      test('does not include id in JSON output', () {
        final json = createValidJson(crewCount: 1);
        final entry = LogbookEntry.fromJson(json);

        final output = entry.toJson();
        expect(output.containsKey('id'), false);
      });

      test('does not include trustLevel in JSON output', () {
        final json = createValidJson(crewCount: 2);
        final entry = LogbookEntry.fromJson(json);

        final output = entry.toJson();
        expect(output.containsKey('trustLevel'), false);
      });

      test('does not include creatorUUID in JSON output', () {
        final json = createValidJson(crewCount: 1);
        final entry = LogbookEntry.fromJson(json);

        final output = entry.toJson();
        expect(output.containsKey('creatorUUID'), false);
      });

      test('formats flightDate as date only', () {
        final json = createValidJson(crewCount: 1);
        final entry = LogbookEntry.fromJson(json);

        final output = entry.toJson();
        expect(output['flightDate'], '2024-06-15');
      });
    });
  });
}
