import 'package:flutter_test/flutter_test.dart';
import 'package:hyperlog/models/pilot.dart';

void main() {
  group('Pilot', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': 'uuid-123-456',
          'pilotLicense': 'UK-ATPL-123456',
          'name': 'John Doe',
          'email': 'john.doe@example.com',
          'status': 'active',
          'createdAt': '2024-01-15T10:30:00.000Z',
          'updatedAt': '2024-06-20T14:45:00.000Z',
        };

        final pilot = Pilot.fromJson(json);

        expect(pilot.id, 'uuid-123-456');
        expect(pilot.licenseNumber, 'UK-ATPL-123456');
        expect(pilot.name, 'John Doe');
        expect(pilot.email, 'john.doe@example.com');
        expect(pilot.status, 'active');
        expect(pilot.createdAt, DateTime.utc(2024, 1, 15, 10, 30));
        expect(pilot.updatedAt, DateTime.utc(2024, 6, 20, 14, 45));
      });

      test('defaults id to empty string when not provided', () {
        final json = {
          'pilotLicense': 'UK-12345',
          'name': 'Jane Doe',
          'email': 'jane@example.com',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final pilot = Pilot.fromJson(json);
        expect(pilot.id, '');
      });

      test('defaults status to active when null', () {
        final json = {
          'id': 'uuid-test',
          'pilotLicense': 'UK-12345',
          'name': 'Jane Doe',
          'email': 'jane@example.com',
          'status': null,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final pilot = Pilot.fromJson(json);
        expect(pilot.status, 'active');
      });

      test('defaults status to active when not provided', () {
        final json = {
          'id': 'uuid-test',
          'pilotLicense': 'UK-12345',
          'name': 'Jane Doe',
          'email': 'jane@example.com',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final pilot = Pilot.fromJson(json);
        expect(pilot.status, 'active');
      });

      test('parses suspended status', () {
        final json = {
          'id': 'uuid-suspended',
          'pilotLicense': 'UK-12345',
          'name': 'Suspended Pilot',
          'email': 'suspended@example.com',
          'status': 'suspended',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final pilot = Pilot.fromJson(json);
        expect(pilot.status, 'suspended');
      });

      test('parses revoked status', () {
        final json = {
          'id': 'uuid-revoked',
          'pilotLicense': 'UK-12345',
          'name': 'Revoked Pilot',
          'email': 'revoked@example.com',
          'status': 'revoked',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final pilot = Pilot.fromJson(json);
        expect(pilot.status, 'revoked');
      });

      test('throws FormatException for invalid createdAt date', () {
        final json = {
          'id': 'uuid-test',
          'pilotLicense': 'UK-12345',
          'name': 'John Doe',
          'email': 'john@example.com',
          'status': 'active',
          'createdAt': 'invalid-date',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        expect(() => Pilot.fromJson(json), throwsFormatException);
      });

      test('throws FormatException for invalid updatedAt date', () {
        final json = {
          'id': 'uuid-test',
          'pilotLicense': 'UK-12345',
          'name': 'John Doe',
          'email': 'john@example.com',
          'status': 'active',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': 'invalid-date',
        };

        expect(() => Pilot.fromJson(json), throwsFormatException);
      });
    });

    group('toJson', () {
      test('serializes required fields correctly', () {
        final pilot = Pilot(
          id: 'uuid-serialize-test',
          licenseNumber: 'UK-ATPL-123456',
          name: 'John Doe',
          email: 'john@example.com',
          status: 'active',
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 15),
        );

        final json = pilot.toJson();

        expect(json['licenseNumber'], 'UK-ATPL-123456');
        expect(json['name'], 'John Doe');
        expect(json['email'], 'john@example.com');
      });

      test('does not include status in JSON output', () {
        final pilot = Pilot(
          id: 'uuid-status-test',
          licenseNumber: 'UK-12345',
          name: 'John Doe',
          email: 'john@example.com',
          status: 'suspended',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final json = pilot.toJson();
        expect(json.containsKey('status'), false);
      });

      test('does not include timestamps in JSON output', () {
        final pilot = Pilot(
          id: 'uuid-timestamp-test',
          licenseNumber: 'UK-12345',
          name: 'John Doe',
          email: 'john@example.com',
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final json = pilot.toJson();
        expect(json.containsKey('createdAt'), false);
        expect(json.containsKey('updatedAt'), false);
      });
    });

    group('isActive', () {
      test('returns true when status is active', () {
        final pilot = Pilot(
          id: 'uuid-active',
          licenseNumber: 'UK-12345',
          name: 'Active Pilot',
          email: 'active@example.com',
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(pilot.isActive, true);
      });

      test('returns false when status is suspended', () {
        final pilot = Pilot(
          id: 'uuid-suspended',
          licenseNumber: 'UK-12345',
          name: 'Suspended Pilot',
          email: 'suspended@example.com',
          status: 'suspended',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(pilot.isActive, false);
      });

      test('returns false when status is revoked', () {
        final pilot = Pilot(
          id: 'uuid-revoked',
          licenseNumber: 'UK-12345',
          name: 'Revoked Pilot',
          email: 'revoked@example.com',
          status: 'revoked',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(pilot.isActive, false);
      });

      test('returns false for unknown status', () {
        final pilot = Pilot(
          id: 'uuid-unknown',
          licenseNumber: 'UK-12345',
          name: 'Unknown Status Pilot',
          email: 'unknown@example.com',
          status: 'unknown',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(pilot.isActive, false);
      });
    });

    group('constructor', () {
      test('creates pilot with all required fields', () {
        final now = DateTime.now();
        final pilot = Pilot(
          id: 'uuid-constructor-test',
          licenseNumber: 'UK-PPL-999',
          name: 'Test Pilot',
          email: 'test@aviation.com',
          status: 'active',
          createdAt: now,
          updatedAt: now,
        );

        expect(pilot.id, 'uuid-constructor-test');
        expect(pilot.licenseNumber, 'UK-PPL-999');
        expect(pilot.name, 'Test Pilot');
        expect(pilot.email, 'test@aviation.com');
        expect(pilot.status, 'active');
        expect(pilot.createdAt, now);
        expect(pilot.updatedAt, now);
      });
    });
  });
}
