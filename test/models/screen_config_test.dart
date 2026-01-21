import 'package:flutter_test/flutter_test.dart';
import 'package:hyperlog/constants/flight_fields.dart';
import 'package:hyperlog/models/screen_config.dart';

void main() {
  group('ScreenConfig', () {
    group('constructor', () {
      test('creates with required fields', () {
        final config = ScreenConfig(
          id: 'test-id',
          name: 'Test Screen',
        );

        expect(config.id, 'test-id');
        expect(config.name, 'Test Screen');
        expect(config.hiddenFields, isEmpty);
      });

      test('creates with hidden fields', () {
        final hidden = {FlightField.flightNumber, FlightField.remarks};
        final config = ScreenConfig(
          id: 'test-id',
          name: 'Test Screen',
          hiddenFields: hidden,
        );

        expect(config.hiddenFields, hidden);
        expect(config.hiddenFields.length, 2);
      });

      test('creates with custom timestamps', () {
        final created = DateTime(2024, 1, 15);
        final updated = DateTime(2024, 1, 20);
        final config = ScreenConfig(
          id: 'test-id',
          name: 'Test',
          createdAt: created,
          updatedAt: updated,
        );

        expect(config.createdAt, created);
        expect(config.updatedAt, updated);
      });
    });

    group('allVisible factory', () {
      test('creates config with no hidden fields', () {
        final config = ScreenConfig.allVisible(
          id: 'visible-id',
          name: 'All Visible',
        );

        expect(config.id, 'visible-id');
        expect(config.name, 'All Visible');
        expect(config.hiddenFields, isEmpty);
      });

      test('all FlightField values are visible', () {
        final config = ScreenConfig.allVisible(
          id: 'test',
          name: 'Test',
        );

        for (final field in FlightField.values) {
          expect(config.isFieldVisible(field), true,
              reason: '${field.name} should be visible');
        }
      });
    });

    group('isFieldVisible / isFieldHidden', () {
      test('returns true for visible fields', () {
        final config = ScreenConfig(
          id: 'test',
          name: 'Test',
          hiddenFields: {FlightField.flightNumber},
        );

        expect(config.isFieldVisible(FlightField.remarks), true);
        expect(config.isFieldVisible(FlightField.approaches), true);
      });

      test('returns false for hidden fields', () {
        final config = ScreenConfig(
          id: 'test',
          name: 'Test',
          hiddenFields: {FlightField.flightNumber, FlightField.remarks},
        );

        expect(config.isFieldVisible(FlightField.flightNumber), false);
        expect(config.isFieldVisible(FlightField.remarks), false);
      });

      test('isFieldHidden is inverse of isFieldVisible', () {
        final config = ScreenConfig(
          id: 'test',
          name: 'Test',
          hiddenFields: {FlightField.approaches},
        );

        expect(config.isFieldHidden(FlightField.approaches), true);
        expect(config.isFieldHidden(FlightField.remarks), false);
      });
    });

    group('copyWith', () {
      test('creates copy with updated name', () {
        final original = ScreenConfig(
          id: 'test-id',
          name: 'Original',
          hiddenFields: {FlightField.flightNumber},
        );

        final copy = original.copyWith(name: 'Updated');

        expect(copy.id, 'test-id');
        expect(copy.name, 'Updated');
        expect(copy.hiddenFields, original.hiddenFields);
      });

      test('creates copy with updated hidden fields', () {
        final original = ScreenConfig(
          id: 'test-id',
          name: 'Test',
        );

        final newHidden = {FlightField.remarks, FlightField.approaches};
        final copy = original.copyWith(hiddenFields: newHidden);

        expect(copy.hiddenFields, newHidden);
        expect(original.hiddenFields, isEmpty);
      });

      test('updates updatedAt timestamp', () {
        final original = ScreenConfig(
          id: 'test',
          name: 'Test',
          updatedAt: DateTime(2024, 1, 1),
        );

        final copy = original.copyWith(name: 'Updated');

        expect(copy.updatedAt.isAfter(original.updatedAt), true);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final created = DateTime.utc(2024, 1, 15, 10, 30);
        final updated = DateTime.utc(2024, 1, 20, 14, 45);
        final config = ScreenConfig(
          id: 'json-test',
          name: 'JSON Test',
          hiddenFields: {FlightField.flightNumber, FlightField.remarks},
          createdAt: created,
          updatedAt: updated,
        );

        final json = config.toJson();

        expect(json['id'], 'json-test');
        expect(json['name'], 'JSON Test');
        expect(json['hiddenFields'], contains('flightNumber'));
        expect(json['hiddenFields'], contains('remarks'));
        expect(json['hiddenFields'], hasLength(2));
        expect(json['createdAt'], created.toIso8601String());
        expect(json['updatedAt'], updated.toIso8601String());
      });

      test('serializes empty hidden fields as empty list', () {
        final config = ScreenConfig(
          id: 'test',
          name: 'Test',
        );

        final json = config.toJson();

        expect(json['hiddenFields'], isEmpty);
      });
    });

    group('fromJson', () {
      test('deserializes all fields correctly', () {
        final json = {
          'id': 'from-json',
          'name': 'From JSON',
          'hiddenFields': ['flightNumber', 'approaches'],
          'createdAt': '2024-01-15T10:30:00.000Z',
          'updatedAt': '2024-01-20T14:45:00.000Z',
        };

        final config = ScreenConfig.fromJson(json);

        expect(config.id, 'from-json');
        expect(config.name, 'From JSON');
        expect(config.hiddenFields, contains(FlightField.flightNumber));
        expect(config.hiddenFields, contains(FlightField.approaches));
        expect(config.hiddenFields.length, 2);
      });

      test('handles missing hiddenFields gracefully', () {
        final json = {
          'id': 'test',
          'name': 'Test',
          'createdAt': '2024-01-15T10:30:00.000Z',
          'updatedAt': '2024-01-20T14:45:00.000Z',
        };

        final config = ScreenConfig.fromJson(json);

        expect(config.hiddenFields, isEmpty);
      });

      test('ignores unknown field names', () {
        final json = {
          'id': 'test',
          'name': 'Test',
          'hiddenFields': ['flightNumber', 'unknownField', 'remarks'],
          'createdAt': '2024-01-15T10:30:00.000Z',
          'updatedAt': '2024-01-20T14:45:00.000Z',
        };

        final config = ScreenConfig.fromJson(json);

        expect(config.hiddenFields.length, 2);
        expect(config.hiddenFields, contains(FlightField.flightNumber));
        expect(config.hiddenFields, contains(FlightField.remarks));
      });

      test('handles malformed dates gracefully', () {
        final json = {
          'id': 'test',
          'name': 'Test',
          'hiddenFields': [],
          'createdAt': 'not-a-date',
          'updatedAt': null,
        };

        final config = ScreenConfig.fromJson(json);

        expect(config.id, 'test');
        expect(config.createdAt, isNotNull);
        expect(config.updatedAt, isNotNull);
      });
    });

    group('equality', () {
      test('configs with same ID are equal', () {
        final config1 = ScreenConfig(id: 'same-id', name: 'Config 1');
        final config2 = ScreenConfig(id: 'same-id', name: 'Config 2');

        expect(config1 == config2, true);
        expect(config1.hashCode, config2.hashCode);
      });

      test('configs with different IDs are not equal', () {
        final config1 = ScreenConfig(id: 'id-1', name: 'Same Name');
        final config2 = ScreenConfig(id: 'id-2', name: 'Same Name');

        expect(config1 == config2, false);
      });
    });

    group('round-trip serialization', () {
      test('toJson then fromJson produces equivalent config', () {
        final original = ScreenConfig(
          id: 'round-trip',
          name: 'Round Trip Test',
          hiddenFields: {
            FlightField.flightNumber,
            FlightField.ifrTime,
            FlightField.approaches,
          },
        );

        final json = original.toJson();
        final restored = ScreenConfig.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.hiddenFields, original.hiddenFields);
      });
    });
  });
}
