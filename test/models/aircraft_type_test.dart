import 'package:flutter_test/flutter_test.dart';
import 'package:hyperlog/models/aircraft_type.dart';

void main() {
  group('AircraftType', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': 1,
          'icaoDesignator': 'A320',
          'manufacturer': 'Airbus',
          'model': 'A320',
          'category': 'LANDPLANE',
          'engineCount': 2,
          'engineType': 'JET',
          'wtc': 'M',
          'multiPilot': true,
          'complex': true,
          'highPerformance': true,
          'retractableGear': true,
        };

        final type = AircraftType.fromJson(json);

        expect(type.id, 1);
        expect(type.icaoDesignator, 'A320');
        expect(type.manufacturer, 'Airbus');
        expect(type.model, 'A320');
        expect(type.category, 'LANDPLANE');
        expect(type.engineCount, 2);
        expect(type.engineType, 'JET');
        expect(type.wtc, 'M');
        expect(type.multiPilot, true);
        expect(type.complex, true);
        expect(type.highPerformance, true);
        expect(type.retractableGear, true);
      });

      test('handles null optional fields', () {
        final json = {
          'id': 1,
          'icaoDesignator': 'C172',
          'manufacturer': 'Cessna',
          'model': '172',
          'category': 'LANDPLANE',
          'engineCount': 1,
          'engineType': 'PISTON',
        };

        final type = AircraftType.fromJson(json);

        expect(type.wtc, isNull);
        expect(type.multiPilot, isNull);
        expect(type.complex, isNull);
        expect(type.highPerformance, isNull);
        expect(type.retractableGear, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final type = AircraftType(
          id: 1,
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
        );

        final json = type.toJson();

        expect(json['id'], 1);
        expect(json['icaoDesignator'], 'B738');
        expect(json['manufacturer'], 'Boeing');
        expect(json['model'], '737-800');
        expect(json['wtc'], 'M');
      });

      test('omits null optional fields', () {
        final type = AircraftType(
          id: 1,
          icaoDesignator: 'C172',
          manufacturer: 'Cessna',
          model: '172',
          category: 'LANDPLANE',
          engineCount: 1,
          engineType: 'PISTON',
        );

        final json = type.toJson();

        expect(json.containsKey('wtc'), false);
        expect(json.containsKey('multiPilot'), false);
        expect(json.containsKey('complex'), false);
        expect(json.containsKey('highPerformance'), false);
        expect(json.containsKey('retractableGear'), false);
      });
    });

    group('displayName', () {
      test('returns ICAO - Manufacturer Model format', () {
        final type = AircraftType(
          id: 1,
          icaoDesignator: 'C172',
          manufacturer: 'Cessna',
          model: '172 Skyhawk',
          category: 'LANDPLANE',
          engineCount: 1,
          engineType: 'PISTON',
        );

        expect(type.displayName, 'C172 - Cessna 172 Skyhawk');
      });
    });

    group('shortName', () {
      test('returns just the ICAO designator', () {
        final type = AircraftType(
          id: 1,
          icaoDesignator: 'A320',
          manufacturer: 'Airbus',
          model: 'A320',
          category: 'LANDPLANE',
          engineCount: 2,
          engineType: 'JET',
        );

        expect(type.shortName, 'A320');
      });
    });

    group('isMultiEngine', () {
      test('returns false for single engine', () {
        final type = AircraftType(
          id: 1,
          icaoDesignator: 'C172',
          manufacturer: 'Cessna',
          model: '172',
          category: 'LANDPLANE',
          engineCount: 1,
          engineType: 'PISTON',
        );

        expect(type.isMultiEngine, false);
      });

      test('returns true for twin engine', () {
        final type = AircraftType(
          id: 2,
          icaoDesignator: 'BE58',
          manufacturer: 'Beechcraft',
          model: 'Baron 58',
          category: 'LANDPLANE',
          engineCount: 2,
          engineType: 'PISTON',
        );

        expect(type.isMultiEngine, true);
      });

      test('returns true for four engine', () {
        final type = AircraftType(
          id: 3,
          icaoDesignator: 'B744',
          manufacturer: 'Boeing',
          model: '747-400',
          category: 'LANDPLANE',
          engineCount: 4,
          engineType: 'JET',
        );

        expect(type.isMultiEngine, true);
      });
    });

    group('toString', () {
      test('returns displayName', () {
        final type = AircraftType(
          id: 1,
          icaoDesignator: 'DR40',
          manufacturer: 'Robin',
          model: 'DR400',
          category: 'LANDPLANE',
          engineCount: 1,
          engineType: 'PISTON',
        );

        expect(type.toString(), 'DR40 - Robin DR400');
      });
    });
  });
}
