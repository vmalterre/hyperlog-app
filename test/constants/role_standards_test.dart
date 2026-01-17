import 'package:flutter_test/flutter_test.dart';
import 'package:hyperlog/constants/role_standards.dart';

void main() {
  group('RoleStandard', () {
    test('has four values', () {
      expect(RoleStandard.values.length, 4);
      expect(RoleStandard.values, contains(RoleStandard.easa));
      expect(RoleStandard.values, contains(RoleStandard.faa));
      expect(RoleStandard.values, contains(RoleStandard.ukCaa));
      expect(RoleStandard.values, contains(RoleStandard.descriptive));
    });
  });

  group('TimeFieldCodes', () {
    test('has 5 time field codes', () {
      expect(TimeFieldCodes.all.length, 5);
      expect(TimeFieldCodes.all, contains('PIC'));
      expect(TimeFieldCodes.all, contains('PICUS'));
      expect(TimeFieldCodes.all, contains('SIC'));
      expect(TimeFieldCodes.all, contains('DUAL'));
      expect(TimeFieldCodes.all, contains('INSTRUCTOR'));
    });

    test('has 3 primary roles', () {
      expect(TimeFieldCodes.primary.length, 3);
      expect(TimeFieldCodes.primary, contains('PIC'));
      expect(TimeFieldCodes.primary, contains('SIC'));
      expect(TimeFieldCodes.primary, contains('PICUS'));
    });

    test('has 2 secondary roles', () {
      expect(TimeFieldCodes.secondary.length, 2);
      expect(TimeFieldCodes.secondary, contains('DUAL'));
      expect(TimeFieldCodes.secondary, contains('INSTRUCTOR'));
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

      test('returns UK CAA for ukCaa standard', () {
        expect(RoleStandards.getDisplayName(RoleStandard.ukCaa), 'UK CAA');
      });

      test('returns Descriptive for descriptive standard', () {
        expect(RoleStandards.getDisplayName(RoleStandard.descriptive), 'Descriptive');
      });
    });

    group('getSubtitle', () {
      test('returns European description for EASA', () {
        final subtitle = RoleStandards.getSubtitle(RoleStandard.easa);
        expect(subtitle, contains('European'));
        expect(subtitle, contains('P1')); // EASA label for PIC
      });

      test('returns American description for FAA', () {
        final subtitle = RoleStandards.getSubtitle(RoleStandard.faa);
        expect(subtitle, contains('American'));
        expect(subtitle, contains('Pilot in Command')); // FAA label for PIC
      });

      test('returns UK description for UK CAA', () {
        final subtitle = RoleStandards.getSubtitle(RoleStandard.ukCaa);
        expect(subtitle, contains('UK'));
        expect(subtitle, contains('P1')); // UK CAA label for PIC
      });

      test('returns Plain English description for Descriptive', () {
        final subtitle = RoleStandards.getSubtitle(RoleStandard.descriptive);
        expect(subtitle, contains('Plain English'));
        expect(subtitle, contains('Captain')); // Descriptive label for PIC
      });
    });

    group('getLabel', () {
      test('returns correct labels for EASA', () {
        expect(RoleStandards.getLabel(RoleStandard.easa, 'PIC'), 'P1');
        expect(RoleStandards.getLabel(RoleStandard.easa, 'SIC'), 'Co-pilot');
        expect(RoleStandards.getLabel(RoleStandard.easa, 'PICUS'), 'P1 u/s');
        expect(RoleStandards.getLabel(RoleStandard.easa, 'DUAL'), 'Dual');
        expect(RoleStandards.getLabel(RoleStandard.easa, 'INSTRUCTOR'), 'Instructor');
      });

      test('returns correct labels for FAA', () {
        expect(RoleStandards.getLabel(RoleStandard.faa, 'PIC'), 'Pilot in Command');
        expect(RoleStandards.getLabel(RoleStandard.faa, 'SIC'), 'Second in Command');
        expect(RoleStandards.getLabel(RoleStandard.faa, 'PICUS'), 'PICUS');
        expect(RoleStandards.getLabel(RoleStandard.faa, 'DUAL'), 'Dual Received');
        expect(RoleStandards.getLabel(RoleStandard.faa, 'INSTRUCTOR'), 'Flight Instructor');
      });

      test('returns correct labels for UK CAA', () {
        expect(RoleStandards.getLabel(RoleStandard.ukCaa, 'PIC'), 'P1');
        expect(RoleStandards.getLabel(RoleStandard.ukCaa, 'SIC'), 'P2');
        expect(RoleStandards.getLabel(RoleStandard.ukCaa, 'PICUS'), 'PICUS');
      });

      test('returns correct labels for Descriptive', () {
        expect(RoleStandards.getLabel(RoleStandard.descriptive, 'PIC'), 'Captain');
        expect(RoleStandards.getLabel(RoleStandard.descriptive, 'SIC'), 'Co-Pilot');
        expect(RoleStandards.getLabel(RoleStandard.descriptive, 'PICUS'), 'PIC Under Supervision');
        expect(RoleStandards.getLabel(RoleStandard.descriptive, 'DUAL'), 'Student');
        expect(RoleStandards.getLabel(RoleStandard.descriptive, 'INSTRUCTOR'), 'Instructor');
      });

      test('returns code itself for unknown role', () {
        expect(RoleStandards.getLabel(RoleStandard.easa, 'UNKNOWN'), 'UNKNOWN');
      });
    });

    group('getDescription', () {
      test('returns description for known codes', () {
        expect(RoleStandards.getDescription('PIC'), 'Pilot in Command time');
        expect(RoleStandards.getDescription('SIC'), 'Second in Command time');
        expect(RoleStandards.getDescription('PICUS'), 'PIC under supervision time');
        expect(RoleStandards.getDescription('DUAL'), 'Dual instruction received time');
        expect(RoleStandards.getDescription('INSTRUCTOR'), 'Flight instruction given time');
      });

      test('returns code itself for unknown code', () {
        expect(RoleStandards.getDescription('UNKNOWN'), 'UNKNOWN');
      });
    });

    group('getRoles (legacy)', () {
      test('returns primary roles with labels for EASA', () {
        final roles = RoleStandards.getRoles(RoleStandard.easa);
        expect(roles.length, 3); // Primary roles only
        expect(roles.map((r) => r.code), contains('PIC'));
        expect(roles.map((r) => r.code), contains('SIC'));
        expect(roles.map((r) => r.code), contains('PICUS'));
      });

      test('returns primary roles with labels for FAA', () {
        final roles = RoleStandards.getRoles(RoleStandard.faa);
        expect(roles.length, 3);
        final picRole = roles.firstWhere((r) => r.code == 'PIC');
        expect(picRole.description, 'Pilot in Command');
      });
    });

    group('getRoleCodes (legacy)', () {
      test('returns primary role codes', () {
        final codes = RoleStandards.getRoleCodes(RoleStandard.easa);
        expect(codes, ['PIC', 'SIC', 'PICUS']);
      });
    });

    group('getDefaultRole', () {
      test('returns PIC for all standards', () {
        expect(RoleStandards.getDefaultRole(RoleStandard.easa), 'PIC');
        expect(RoleStandards.getDefaultRole(RoleStandard.faa), 'PIC');
        expect(RoleStandards.getDefaultRole(RoleStandard.ukCaa), 'PIC');
        expect(RoleStandards.getDefaultRole(RoleStandard.descriptive), 'PIC');
      });
    });

    group('getPrimaryRolesWithLabels', () {
      test('returns primary roles with labels', () {
        final roles = RoleStandards.getPrimaryRolesWithLabels(RoleStandard.faa);
        expect(roles.length, 3);
        expect(roles.map((r) => r.code), contains('PIC'));
        expect(roles.map((r) => r.code), contains('SIC'));
        expect(roles.map((r) => r.code), contains('PICUS'));

        final picRole = roles.firstWhere((r) => r.code == 'PIC');
        expect(picRole.label, 'Pilot in Command');
      });
    });

    group('getSecondaryRolesWithLabels', () {
      test('returns secondary roles with labels', () {
        final roles = RoleStandards.getSecondaryRolesWithLabels(RoleStandard.faa);
        expect(roles.length, 2);
        expect(roles.map((r) => r.code), contains('DUAL'));
        expect(roles.map((r) => r.code), contains('INSTRUCTOR'));

        final dualRole = roles.firstWhere((r) => r.code == 'DUAL');
        expect(dualRole.label, 'Dual Received');
      });
    });

    group('isPrimaryRole / isSecondaryRole', () {
      test('correctly identifies primary roles', () {
        expect(RoleStandards.isPrimaryRole('PIC'), true);
        expect(RoleStandards.isPrimaryRole('SIC'), true);
        expect(RoleStandards.isPrimaryRole('PICUS'), true);
        expect(RoleStandards.isPrimaryRole('DUAL'), false);
        expect(RoleStandards.isPrimaryRole('INSTRUCTOR'), false);
      });

      test('correctly identifies secondary roles', () {
        expect(RoleStandards.isSecondaryRole('DUAL'), true);
        expect(RoleStandards.isSecondaryRole('INSTRUCTOR'), true);
        expect(RoleStandards.isSecondaryRole('PIC'), false);
        expect(RoleStandards.isSecondaryRole('SIC'), false);
      });
    });
  });
}
