import 'package:flutter_test/flutter_test.dart';
import 'package:hyperlog/models/aircraft_type.dart';
import 'package:hyperlog/models/user_aircraft_type.dart';
import 'package:hyperlog/models/user_aircraft_registration.dart';

void main() {
  group('UserAircraftRegistration', () {
    final now = DateTime.now();

    // Sample aircraft type for testing
    final sampleAircraftType = AircraftType(
      id: 1,
      icaoDesignator: 'DR40',
      manufacturer: 'Robin',
      model: 'DR400',
      category: 'LANDPLANE',
      engineCount: 1,
      engineType: 'PISTON',
      wtc: 'L',
      multiPilot: false,
      complex: false,
      highPerformance: false,
      retractableGear: false,
    );

    // Sample user aircraft type
    final sampleUserAircraftType = UserAircraftType(
      id: 'uat-123',
      pilotId: 'pilot-456',
      aircraftTypeId: 1,
      multiEngine: false,
      multiPilot: false,
      engineType: 'PISTON',
      complex: false,
      highPerformance: false,
      category: 'LANDPLANE',
      variant: 'Remorqueur',
      createdAt: now,
      updatedAt: now,
      aircraftType: sampleAircraftType,
    );

    // Multi-engine type for testing
    final multiEngineType = UserAircraftType(
      id: 'uat-456',
      pilotId: 'pilot-456',
      aircraftTypeId: 2,
      multiEngine: true,
      multiPilot: true,
      engineType: 'JET',
      complex: true,
      highPerformance: true,
      category: 'LANDPLANE',
      createdAt: now,
      updatedAt: now,
      aircraftType: AircraftType(
        id: 2,
        icaoDesignator: 'B738',
        manufacturer: 'Boeing',
        model: '737-800',
        category: 'LANDPLANE',
        engineCount: 2,
        engineType: 'JET',
        wtc: 'M',
        multiPilot: true,
        complex: true,
        highPerformance: true,
        retractableGear: true,
      ),
    );

    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': 'reg-123',
          'pilotId': 'pilot-456',
          'registration': 'F-GZTP',
          'userAircraftTypeId': 'uat-123',
          'notes': 'Club aircraft - Book 48h ahead',
          'createdAt': '2024-01-15T10:30:00.000Z',
          'updatedAt': '2024-01-16T14:20:00.000Z',
        };

        final reg = UserAircraftRegistration.fromJson(json);

        expect(reg.id, 'reg-123');
        expect(reg.pilotId, 'pilot-456');
        expect(reg.registration, 'F-GZTP');
        expect(reg.userAircraftTypeId, 'uat-123');
        expect(reg.notes, 'Club aircraft - Book 48h ahead');
      });

      test('parses with nested userAircraftType', () {
        final json = {
          'id': 'reg-123',
          'pilotId': 'pilot-456',
          'registration': 'F-GZTP',
          'userAircraftTypeId': 'uat-123',
          'createdAt': '2024-01-15T10:30:00.000Z',
          'updatedAt': '2024-01-16T14:20:00.000Z',
          'userAircraftType': {
            'id': 'uat-123',
            'pilotId': 'pilot-456',
            'aircraftTypeId': 1,
            'multiEngine': false,
            'multiPilot': false,
            'engineType': 'PISTON',
            'complex': false,
            'highPerformance': false,
            'category': 'LANDPLANE',
            'variant': 'Remorqueur',
            'createdAt': '2024-01-15T10:30:00.000Z',
            'updatedAt': '2024-01-16T14:20:00.000Z',
            'aircraftType': {
              'id': 1,
              'icaoDesignator': 'DR40',
              'manufacturer': 'Robin',
              'model': 'DR400',
              'category': 'LANDPLANE',
              'engineCount': 1,
              'engineType': 'PISTON',
              'wtc': 'L',
              'multiPilot': false,
              'complex': false,
              'highPerformance': false,
              'retractableGear': false,
            },
          },
        };

        final reg = UserAircraftRegistration.fromJson(json);

        expect(reg.userAircraftType, isNotNull);
        expect(reg.userAircraftType!.variant, 'Remorqueur');
        expect(reg.userAircraftType!.aircraftType!.icaoDesignator, 'DR40');
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'reg-123',
          'pilotId': 'pilot-456',
          'registration': 'G-ABCD',
          'userAircraftTypeId': 'uat-123',
          'createdAt': '2024-01-15T10:30:00.000Z',
          'updatedAt': '2024-01-16T14:20:00.000Z',
        };

        final reg = UserAircraftRegistration.fromJson(json);

        expect(reg.notes, isNull);
        expect(reg.userAircraftType, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final reg = UserAircraftRegistration(
          id: 'reg-123',
          pilotId: 'pilot-456',
          registration: 'F-GZTP',
          userAircraftTypeId: 'uat-123',
          notes: 'Test notes',
          createdAt: DateTime.parse('2024-01-15T10:30:00.000Z'),
          updatedAt: DateTime.parse('2024-01-16T14:20:00.000Z'),
        );

        final json = reg.toJson();

        expect(json['id'], 'reg-123');
        expect(json['registration'], 'F-GZTP');
        expect(json['notes'], 'Test notes');
      });

      test('omits null optional fields', () {
        final reg = UserAircraftRegistration(
          id: 'reg-123',
          pilotId: 'pilot-456',
          registration: 'F-GZTP',
          userAircraftTypeId: 'uat-123',
          createdAt: now,
          updatedAt: now,
        );

        final json = reg.toJson();

        expect(json.containsKey('notes'), false);
        expect(json.containsKey('userAircraftType'), false);
      });

      test('includes nested userAircraftType when present', () {
        final reg = UserAircraftRegistration(
          id: 'reg-123',
          pilotId: 'pilot-456',
          registration: 'F-GZTP',
          userAircraftTypeId: 'uat-123',
          createdAt: now,
          updatedAt: now,
          userAircraftType: sampleUserAircraftType,
        );

        final json = reg.toJson();

        expect(json.containsKey('userAircraftType'), true);
        expect(json['userAircraftType']['variant'], 'Remorqueur');
      });
    });

    group('aircraftTypeDisplay', () {
      test('returns displayNameWithVariant when userAircraftType present', () {
        final reg = UserAircraftRegistration(
          id: 'reg-123',
          pilotId: 'pilot-456',
          registration: 'F-GZTP',
          userAircraftTypeId: 'uat-123',
          createdAt: now,
          updatedAt: now,
          userAircraftType: sampleUserAircraftType,
        );

        expect(reg.aircraftTypeDisplay, 'Robin DR400 (Remorqueur)');
      });

      test('returns Unknown when userAircraftType is null', () {
        final reg = UserAircraftRegistration(
          id: 'reg-123',
          pilotId: 'pilot-456',
          registration: 'F-GZTP',
          userAircraftTypeId: 'uat-123',
          createdAt: now,
          updatedAt: now,
        );

        expect(reg.aircraftTypeDisplay, 'Unknown');
      });
    });

    group('icaoDesignator', () {
      test('returns ICAO from nested type', () {
        final reg = UserAircraftRegistration(
          id: 'reg-123',
          pilotId: 'pilot-456',
          registration: 'F-GZTP',
          userAircraftTypeId: 'uat-123',
          createdAt: now,
          updatedAt: now,
          userAircraftType: sampleUserAircraftType,
        );

        expect(reg.icaoDesignator, 'DR40');
      });

      test('returns empty string when type is null', () {
        final reg = UserAircraftRegistration(
          id: 'reg-123',
          pilotId: 'pilot-456',
          registration: 'F-GZTP',
          userAircraftTypeId: 'uat-123',
          createdAt: now,
          updatedAt: now,
        );

        expect(reg.icaoDesignator, '');
      });
    });

    group('isMultiEngine', () {
      test('returns false for single engine aircraft', () {
        final reg = UserAircraftRegistration(
          id: 'reg-123',
          pilotId: 'pilot-456',
          registration: 'F-GZTP',
          userAircraftTypeId: 'uat-123',
          createdAt: now,
          updatedAt: now,
          userAircraftType: sampleUserAircraftType,
        );

        expect(reg.isMultiEngine, false);
      });

      test('returns true for multi-engine aircraft', () {
        final reg = UserAircraftRegistration(
          id: 'reg-456',
          pilotId: 'pilot-456',
          registration: 'G-JETS',
          userAircraftTypeId: 'uat-456',
          createdAt: now,
          updatedAt: now,
          userAircraftType: multiEngineType,
        );

        expect(reg.isMultiEngine, true);
      });

      test('returns false when type is null', () {
        final reg = UserAircraftRegistration(
          id: 'reg-123',
          pilotId: 'pilot-456',
          registration: 'F-GZTP',
          userAircraftTypeId: 'uat-123',
          createdAt: now,
          updatedAt: now,
        );

        expect(reg.isMultiEngine, false);
      });
    });

    group('isMultiPilot', () {
      test('returns correct value', () {
        final singlePilot = UserAircraftRegistration(
          id: 'reg-123',
          pilotId: 'pilot-456',
          registration: 'F-GZTP',
          userAircraftTypeId: 'uat-123',
          createdAt: now,
          updatedAt: now,
          userAircraftType: sampleUserAircraftType,
        );

        final multiPilot = UserAircraftRegistration(
          id: 'reg-456',
          pilotId: 'pilot-456',
          registration: 'G-JETS',
          userAircraftTypeId: 'uat-456',
          createdAt: now,
          updatedAt: now,
          userAircraftType: multiEngineType,
        );

        expect(singlePilot.isMultiPilot, false);
        expect(multiPilot.isMultiPilot, true);
      });
    });

    group('isComplex', () {
      test('returns correct value', () {
        final simple = UserAircraftRegistration(
          id: 'reg-123',
          pilotId: 'pilot-456',
          registration: 'F-GZTP',
          userAircraftTypeId: 'uat-123',
          createdAt: now,
          updatedAt: now,
          userAircraftType: sampleUserAircraftType,
        );

        final complex = UserAircraftRegistration(
          id: 'reg-456',
          pilotId: 'pilot-456',
          registration: 'G-JETS',
          userAircraftTypeId: 'uat-456',
          createdAt: now,
          updatedAt: now,
          userAircraftType: multiEngineType,
        );

        expect(simple.isComplex, false);
        expect(complex.isComplex, true);
      });
    });

    group('isHighPerformance', () {
      test('returns correct value', () {
        final normal = UserAircraftRegistration(
          id: 'reg-123',
          pilotId: 'pilot-456',
          registration: 'F-GZTP',
          userAircraftTypeId: 'uat-123',
          createdAt: now,
          updatedAt: now,
          userAircraftType: sampleUserAircraftType,
        );

        final highPerf = UserAircraftRegistration(
          id: 'reg-456',
          pilotId: 'pilot-456',
          registration: 'G-JETS',
          userAircraftTypeId: 'uat-456',
          createdAt: now,
          updatedAt: now,
          userAircraftType: multiEngineType,
        );

        expect(normal.isHighPerformance, false);
        expect(highPerf.isHighPerformance, true);
      });
    });

    group('engineType', () {
      test('returns engine type from nested type', () {
        final piston = UserAircraftRegistration(
          id: 'reg-123',
          pilotId: 'pilot-456',
          registration: 'F-GZTP',
          userAircraftTypeId: 'uat-123',
          createdAt: now,
          updatedAt: now,
          userAircraftType: sampleUserAircraftType,
        );

        final jet = UserAircraftRegistration(
          id: 'reg-456',
          pilotId: 'pilot-456',
          registration: 'G-JETS',
          userAircraftTypeId: 'uat-456',
          createdAt: now,
          updatedAt: now,
          userAircraftType: multiEngineType,
        );

        expect(piston.engineType, 'PISTON');
        expect(jet.engineType, 'JET');
      });

      test('returns PISTON as default when type is null', () {
        final reg = UserAircraftRegistration(
          id: 'reg-123',
          pilotId: 'pilot-456',
          registration: 'F-GZTP',
          userAircraftTypeId: 'uat-123',
          createdAt: now,
          updatedAt: now,
        );

        expect(reg.engineType, 'PISTON');
      });
    });

    group('category', () {
      test('returns category from nested type', () {
        final reg = UserAircraftRegistration(
          id: 'reg-123',
          pilotId: 'pilot-456',
          registration: 'F-GZTP',
          userAircraftTypeId: 'uat-123',
          createdAt: now,
          updatedAt: now,
          userAircraftType: sampleUserAircraftType,
        );

        expect(reg.category, 'LANDPLANE');
      });

      test('returns LANDPLANE as default when type is null', () {
        final reg = UserAircraftRegistration(
          id: 'reg-123',
          pilotId: 'pilot-456',
          registration: 'F-GZTP',
          userAircraftTypeId: 'uat-123',
          createdAt: now,
          updatedAt: now,
        );

        expect(reg.category, 'LANDPLANE');
      });
    });

    group('toString', () {
      test('returns registration and ICAO', () {
        final reg = UserAircraftRegistration(
          id: 'reg-123',
          pilotId: 'pilot-456',
          registration: 'F-GZTP',
          userAircraftTypeId: 'uat-123',
          createdAt: now,
          updatedAt: now,
          userAircraftType: sampleUserAircraftType,
        );

        expect(reg.toString(), 'F-GZTP (DR40)');
      });
    });
  });
}
