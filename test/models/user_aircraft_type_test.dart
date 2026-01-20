import 'package:flutter_test/flutter_test.dart';
import 'package:hyperlog/models/aircraft_type.dart';
import 'package:hyperlog/models/user_aircraft_type.dart';

void main() {
  group('UserAircraftType', () {
    // Sample aircraft type for testing
    final sampleAircraftType = AircraftType(
      id: 1,
      icaoDesignator: 'C172',
      manufacturer: 'Cessna',
      model: '172 Skyhawk',
      category: 'LANDPLANE',
      engineCount: 1,
      engineType: 'PISTON',
      wtc: 'L',
      multiPilot: false,
      complex: false,
      highPerformance: false,
      retractableGear: false,
    );

    final now = DateTime.now();

    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': 'uat-123',
          'pilotId': 'pilot-456',
          'aircraftTypeId': 1,
          'multiEngine': false,
          'multiPilot': false,
          'engineType': 'PISTON',
          'complex': false,
          'highPerformance': false,
          'category': 'LANDPLANE',
          'variant': 'SP',
          'notes': 'Club aircraft',
          'createdAt': '2024-01-15T10:30:00.000Z',
          'updatedAt': '2024-01-16T14:20:00.000Z',
        };

        final uat = UserAircraftType.fromJson(json);

        expect(uat.id, 'uat-123');
        expect(uat.pilotId, 'pilot-456');
        expect(uat.aircraftTypeId, 1);
        expect(uat.multiEngine, false);
        expect(uat.multiPilot, false);
        expect(uat.engineType, 'PISTON');
        expect(uat.complex, false);
        expect(uat.highPerformance, false);
        expect(uat.category, 'LANDPLANE');
        expect(uat.variant, 'SP');
        expect(uat.notes, 'Club aircraft');
      });

      test('parses with nested aircraftType', () {
        final json = {
          'id': 'uat-123',
          'pilotId': 'pilot-456',
          'aircraftTypeId': 1,
          'multiEngine': false,
          'multiPilot': false,
          'engineType': 'PISTON',
          'complex': false,
          'highPerformance': false,
          'category': 'LANDPLANE',
          'createdAt': '2024-01-15T10:30:00.000Z',
          'updatedAt': '2024-01-16T14:20:00.000Z',
          'aircraftType': {
            'id': 1,
            'icaoDesignator': 'C172',
            'manufacturer': 'Cessna',
            'model': '172 Skyhawk',
            'category': 'LANDPLANE',
            'engineCount': 1,
            'engineType': 'PISTON',
            'wtc': 'L',
            'multiPilot': false,
            'complex': false,
            'highPerformance': false,
            'retractableGear': false,
          },
        };

        final uat = UserAircraftType.fromJson(json);

        expect(uat.aircraftType, isNotNull);
        expect(uat.aircraftType!.icaoDesignator, 'C172');
        expect(uat.aircraftType!.manufacturer, 'Cessna');
      });

      test('uses default values for optional fields', () {
        final json = {
          'id': 'uat-123',
          'pilotId': 'pilot-456',
          'aircraftTypeId': 1,
          'createdAt': '2024-01-15T10:30:00.000Z',
          'updatedAt': '2024-01-16T14:20:00.000Z',
        };

        final uat = UserAircraftType.fromJson(json);

        expect(uat.multiEngine, false);
        expect(uat.multiPilot, false);
        expect(uat.engineType, 'PISTON');
        expect(uat.complex, false);
        expect(uat.highPerformance, false);
        expect(uat.category, 'LANDPLANE');
        expect(uat.variant, isNull);
        expect(uat.notes, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final uat = UserAircraftType(
          id: 'uat-123',
          pilotId: 'pilot-456',
          aircraftTypeId: 1,
          multiEngine: true,
          multiPilot: false,
          engineType: 'TURBOPROP',
          complex: true,
          highPerformance: true,
          category: 'LANDPLANE',
          variant: 'XP',
          notes: 'Personal aircraft',
          createdAt: DateTime.parse('2024-01-15T10:30:00.000Z'),
          updatedAt: DateTime.parse('2024-01-16T14:20:00.000Z'),
        );

        final json = uat.toJson();

        expect(json['id'], 'uat-123');
        expect(json['multiEngine'], true);
        expect(json['engineType'], 'TURBOPROP');
        expect(json['variant'], 'XP');
        expect(json['notes'], 'Personal aircraft');
      });

      test('omits null optional fields', () {
        final uat = UserAircraftType(
          id: 'uat-123',
          pilotId: 'pilot-456',
          aircraftTypeId: 1,
          multiEngine: false,
          multiPilot: false,
          engineType: 'PISTON',
          complex: false,
          highPerformance: false,
          category: 'LANDPLANE',
          createdAt: now,
          updatedAt: now,
        );

        final json = uat.toJson();

        expect(json.containsKey('variant'), false);
        expect(json.containsKey('notes'), false);
        expect(json.containsKey('aircraftType'), false);
      });
    });

    group('displayName', () {
      test('returns manufacturer + model when aircraftType is present', () {
        final uat = UserAircraftType(
          id: 'uat-123',
          pilotId: 'pilot-456',
          aircraftTypeId: 1,
          multiEngine: false,
          multiPilot: false,
          engineType: 'PISTON',
          complex: false,
          highPerformance: false,
          category: 'LANDPLANE',
          createdAt: now,
          updatedAt: now,
          aircraftType: sampleAircraftType,
        );

        expect(uat.displayName, 'Cessna 172 Skyhawk');
      });

      test('returns fallback when aircraftType is null', () {
        final uat = UserAircraftType(
          id: 'uat-123',
          pilotId: 'pilot-456',
          aircraftTypeId: 99,
          multiEngine: false,
          multiPilot: false,
          engineType: 'PISTON',
          complex: false,
          highPerformance: false,
          category: 'LANDPLANE',
          createdAt: now,
          updatedAt: now,
        );

        expect(uat.displayName, 'Unknown Type (99)');
      });
    });

    group('fullDisplayName', () {
      test('returns ICAO - Manufacturer Model without variant', () {
        final uat = UserAircraftType(
          id: 'uat-123',
          pilotId: 'pilot-456',
          aircraftTypeId: 1,
          multiEngine: false,
          multiPilot: false,
          engineType: 'PISTON',
          complex: false,
          highPerformance: false,
          category: 'LANDPLANE',
          createdAt: now,
          updatedAt: now,
          aircraftType: sampleAircraftType,
        );

        expect(uat.fullDisplayName, 'C172 - Cessna 172 Skyhawk');
      });

      test('returns ICAO - Manufacturer Model (Variant) with variant', () {
        final uat = UserAircraftType(
          id: 'uat-123',
          pilotId: 'pilot-456',
          aircraftTypeId: 1,
          multiEngine: false,
          multiPilot: false,
          engineType: 'PISTON',
          complex: false,
          highPerformance: false,
          category: 'LANDPLANE',
          variant: 'SP',
          createdAt: now,
          updatedAt: now,
          aircraftType: sampleAircraftType,
        );

        expect(uat.fullDisplayName, 'C172 - Cessna 172 Skyhawk (SP)');
      });
    });

    group('displayNameWithVariant', () {
      test('returns base name without variant', () {
        final uat = UserAircraftType(
          id: 'uat-123',
          pilotId: 'pilot-456',
          aircraftTypeId: 1,
          multiEngine: false,
          multiPilot: false,
          engineType: 'PISTON',
          complex: false,
          highPerformance: false,
          category: 'LANDPLANE',
          createdAt: now,
          updatedAt: now,
          aircraftType: sampleAircraftType,
        );

        expect(uat.displayNameWithVariant, 'Cessna 172 Skyhawk');
      });

      test('includes variant in parentheses when set', () {
        final uat = UserAircraftType(
          id: 'uat-123',
          pilotId: 'pilot-456',
          aircraftTypeId: 1,
          multiEngine: false,
          multiPilot: false,
          engineType: 'PISTON',
          complex: false,
          highPerformance: false,
          category: 'LANDPLANE',
          variant: 'G1000',
          createdAt: now,
          updatedAt: now,
          aircraftType: sampleAircraftType,
        );

        expect(uat.displayNameWithVariant, 'Cessna 172 Skyhawk (G1000)');
      });

      test('ignores empty string variant', () {
        final uat = UserAircraftType(
          id: 'uat-123',
          pilotId: 'pilot-456',
          aircraftTypeId: 1,
          multiEngine: false,
          multiPilot: false,
          engineType: 'PISTON',
          complex: false,
          highPerformance: false,
          category: 'LANDPLANE',
          variant: '',
          createdAt: now,
          updatedAt: now,
          aircraftType: sampleAircraftType,
        );

        expect(uat.displayNameWithVariant, 'Cessna 172 Skyhawk');
      });
    });

    group('shortDisplayName', () {
      test('returns variant when set', () {
        final uat = UserAircraftType(
          id: 'uat-123',
          pilotId: 'pilot-456',
          aircraftTypeId: 1,
          multiEngine: false,
          multiPilot: false,
          engineType: 'PISTON',
          complex: false,
          highPerformance: false,
          category: 'LANDPLANE',
          variant: 'Club Skyhawk',
          createdAt: now,
          updatedAt: now,
          aircraftType: sampleAircraftType,
        );

        expect(uat.shortDisplayName, 'Club Skyhawk');
      });

      test('returns displayName when variant is null', () {
        final uat = UserAircraftType(
          id: 'uat-123',
          pilotId: 'pilot-456',
          aircraftTypeId: 1,
          multiEngine: false,
          multiPilot: false,
          engineType: 'PISTON',
          complex: false,
          highPerformance: false,
          category: 'LANDPLANE',
          createdAt: now,
          updatedAt: now,
          aircraftType: sampleAircraftType,
        );

        expect(uat.shortDisplayName, 'Cessna 172 Skyhawk');
      });
    });

    group('getters', () {
      test('icaoDesignator returns from aircraftType', () {
        final uat = UserAircraftType(
          id: 'uat-123',
          pilotId: 'pilot-456',
          aircraftTypeId: 1,
          multiEngine: false,
          multiPilot: false,
          engineType: 'PISTON',
          complex: false,
          highPerformance: false,
          category: 'LANDPLANE',
          createdAt: now,
          updatedAt: now,
          aircraftType: sampleAircraftType,
        );

        expect(uat.icaoDesignator, 'C172');
        expect(uat.manufacturer, 'Cessna');
        expect(uat.model, '172 Skyhawk');
      });

      test('getters return empty string when aircraftType is null', () {
        final uat = UserAircraftType(
          id: 'uat-123',
          pilotId: 'pilot-456',
          aircraftTypeId: 1,
          multiEngine: false,
          multiPilot: false,
          engineType: 'PISTON',
          complex: false,
          highPerformance: false,
          category: 'LANDPLANE',
          createdAt: now,
          updatedAt: now,
        );

        expect(uat.icaoDesignator, '');
        expect(uat.manufacturer, '');
        expect(uat.model, '');
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = UserAircraftType(
          id: 'uat-123',
          pilotId: 'pilot-456',
          aircraftTypeId: 1,
          multiEngine: false,
          multiPilot: false,
          engineType: 'PISTON',
          complex: false,
          highPerformance: false,
          category: 'LANDPLANE',
          createdAt: now,
          updatedAt: now,
          aircraftType: sampleAircraftType,
        );

        final copy = original.copyWith(
          multiEngine: true,
          variant: 'Turbo',
        );

        expect(copy.id, original.id);
        expect(copy.multiEngine, true);
        expect(copy.variant, 'Turbo');
        expect(copy.engineType, 'PISTON'); // unchanged
      });

      test('preserves original when no changes specified', () {
        final original = UserAircraftType(
          id: 'uat-123',
          pilotId: 'pilot-456',
          aircraftTypeId: 1,
          multiEngine: true,
          multiPilot: true,
          engineType: 'JET',
          complex: true,
          highPerformance: true,
          category: 'SEAPLANE',
          variant: 'Original',
          createdAt: now,
          updatedAt: now,
        );

        final copy = original.copyWith();

        expect(copy.multiEngine, true);
        expect(copy.multiPilot, true);
        expect(copy.engineType, 'JET');
        expect(copy.variant, 'Original');
      });
    });
  });
}
