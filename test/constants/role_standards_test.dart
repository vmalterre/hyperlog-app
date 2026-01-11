import 'package:flutter_test/flutter_test.dart';
import 'package:hyperlog/constants/role_standards.dart';

void main() {
  group('RoleStandard', () {
    test('has three values', () {
      expect(RoleStandard.values.length, 3);
      expect(RoleStandard.values, contains(RoleStandard.easa));
      expect(RoleStandard.values, contains(RoleStandard.faa));
      expect(RoleStandard.values, contains(RoleStandard.descriptive));
    });
  });

  group('Role', () {
    test('stores code and description', () {
      const role = Role('PIC', 'Pilot In Command');
      expect(role.code, 'PIC');
      expect(role.description, 'Pilot In Command');
    });
  });

  group('RoleStandards', () {
    group('getDisplayName', () {
      test('returns EASA for easa standard', () {
        expect(RoleStandards.getDisplayName(RoleStandard.easa), 'EASA');
      });

      test('returns FAA for faa standard', () {
        expect(RoleStandards.getDisplayName(RoleStandard.faa), 'FAA');
      });

      test('returns Descriptive for descriptive standard', () {
        expect(RoleStandards.getDisplayName(RoleStandard.descriptive), 'Descriptive');
      });
    });

    group('getSubtitle', () {
      test('returns European description for EASA', () {
        final subtitle = RoleStandards.getSubtitle(RoleStandard.easa);
        expect(subtitle, contains('European'));
        expect(subtitle, contains('PIC'));
        expect(subtitle, contains('SIC'));
      });

      test('returns American description for FAA', () {
        final subtitle = RoleStandards.getSubtitle(RoleStandard.faa);
        expect(subtitle, contains('American'));
        expect(subtitle, contains('PIC'));
        expect(subtitle, contains('CFI'));
      });

      test('returns Plain English description for Descriptive', () {
        final subtitle = RoleStandards.getSubtitle(RoleStandard.descriptive);
        expect(subtitle, contains('Plain English'));
        expect(subtitle, contains('Captain'));
      });
    });

    group('getRoles', () {
      test('returns EASA roles list', () {
        final roles = RoleStandards.getRoles(RoleStandard.easa);
        expect(roles.length, 11);
        expect(roles.map((r) => r.code), contains('PIC'));
        expect(roles.map((r) => r.code), contains('SIC'));
        expect(roles.map((r) => r.code), contains('DUAL'));
        expect(roles.map((r) => r.code), contains('PICUS'));
        expect(roles.map((r) => r.code), contains('FI'));
        expect(roles.map((r) => r.code), contains('FE'));
      });

      test('returns FAA roles list', () {
        final roles = RoleStandards.getRoles(RoleStandard.faa);
        expect(roles.length, 6);
        expect(roles.map((r) => r.code), contains('PIC'));
        expect(roles.map((r) => r.code), contains('SIC'));
        expect(roles.map((r) => r.code), contains('DUAL'));
        expect(roles.map((r) => r.code), contains('SOLO'));
        expect(roles.map((r) => r.code), contains('CFI'));
        expect(roles.map((r) => r.code), contains('SP'));
      });

      test('returns Descriptive roles list', () {
        final roles = RoleStandards.getRoles(RoleStandard.descriptive);
        expect(roles.length, 6);
        expect(roles.map((r) => r.code), contains('Captain'));
        expect(roles.map((r) => r.code), contains('Co-Pilot'));
        expect(roles.map((r) => r.code), contains('Student'));
        expect(roles.map((r) => r.code), contains('Instructor'));
        expect(roles.map((r) => r.code), contains('Observer'));
        expect(roles.map((r) => r.code), contains('Safety Pilot'));
      });
    });

    group('getRoleCodes', () {
      test('returns only codes for EASA', () {
        final codes = RoleStandards.getRoleCodes(RoleStandard.easa);
        expect(codes, isA<List<String>>());
        expect(codes, contains('PIC'));
        expect(codes, contains('PICUS'));
        expect(codes.length, 11);
      });

      test('returns only codes for FAA', () {
        final codes = RoleStandards.getRoleCodes(RoleStandard.faa);
        expect(codes, ['PIC', 'SIC', 'DUAL', 'SOLO', 'CFI', 'SP']);
      });

      test('returns only codes for Descriptive', () {
        final codes = RoleStandards.getRoleCodes(RoleStandard.descriptive);
        expect(codes.first, 'Captain');
        expect(codes.length, 6);
      });
    });

    group('getDescription', () {
      test('returns description for valid EASA role', () {
        final desc = RoleStandards.getDescription(RoleStandard.easa, 'PIC');
        expect(desc, 'Pilot In Command');
      });

      test('returns description for valid FAA role', () {
        final desc = RoleStandards.getDescription(RoleStandard.faa, 'CFI');
        expect(desc, 'Certificated Flight Instructor');
      });

      test('returns description for valid Descriptive role', () {
        final desc = RoleStandards.getDescription(RoleStandard.descriptive, 'Captain');
        expect(desc, 'Flying as captain');
      });

      test('returns code itself for unknown role', () {
        final desc = RoleStandards.getDescription(RoleStandard.easa, 'UNKNOWN');
        expect(desc, 'UNKNOWN');
      });
    });

    group('getDefaultRole', () {
      test('returns PIC for EASA', () {
        expect(RoleStandards.getDefaultRole(RoleStandard.easa), 'PIC');
      });

      test('returns PIC for FAA', () {
        expect(RoleStandards.getDefaultRole(RoleStandard.faa), 'PIC');
      });

      test('returns Captain for Descriptive', () {
        expect(RoleStandards.getDefaultRole(RoleStandard.descriptive), 'Captain');
      });
    });

    group('roles map', () {
      test('contains all three standards', () {
        expect(RoleStandards.roles.keys, contains(RoleStandard.easa));
        expect(RoleStandards.roles.keys, contains(RoleStandard.faa));
        expect(RoleStandards.roles.keys, contains(RoleStandard.descriptive));
      });

      test('all roles have non-empty code and description', () {
        for (final standard in RoleStandard.values) {
          final roles = RoleStandards.getRoles(standard);
          for (final role in roles) {
            expect(role.code, isNotEmpty, reason: 'Role code should not be empty');
            expect(role.description, isNotEmpty, reason: 'Role description should not be empty');
          }
        }
      });
    });
  });
}
