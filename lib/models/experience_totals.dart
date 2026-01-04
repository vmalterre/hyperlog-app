import 'logbook_entry.dart';
import '../utils/aircraft_categorizer.dart';

/// Aggregated experience totals calculated from flights
class ExperienceTotals {
  final int totalMinutes;
  final int picMinutes;
  final int sicMinutes;
  final int dualMinutes;
  final int nightMinutes;
  final int ifrMinutes;
  final int dayLandings;
  final int nightLandings;
  final int jetMinutes;
  final int gaPistonMinutes;

  const ExperienceTotals({
    required this.totalMinutes,
    required this.picMinutes,
    required this.sicMinutes,
    required this.dualMinutes,
    required this.nightMinutes,
    required this.ifrMinutes,
    required this.dayLandings,
    required this.nightLandings,
    required this.jetMinutes,
    required this.gaPistonMinutes,
  });

  /// Create empty totals
  const ExperienceTotals.empty()
      : totalMinutes = 0,
        picMinutes = 0,
        sicMinutes = 0,
        dualMinutes = 0,
        nightMinutes = 0,
        ifrMinutes = 0,
        dayLandings = 0,
        nightLandings = 0,
        jetMinutes = 0,
        gaPistonMinutes = 0;

  /// Aggregate totals from a list of flights
  factory ExperienceTotals.fromFlights(List<LogbookEntry> flights) {
    if (flights.isEmpty) return const ExperienceTotals.empty();

    int totalMinutes = 0;
    int picMinutes = 0;
    int sicMinutes = 0;
    int dualMinutes = 0;
    int nightMinutes = 0;
    int ifrMinutes = 0;
    int dayLandings = 0;
    int nightLandings = 0;
    int jetMinutes = 0;
    int gaPistonMinutes = 0;

    for (final flight in flights) {
      final ft = flight.flightTime;

      totalMinutes += ft.total;
      picMinutes += ft.pic;
      sicMinutes += ft.sic;
      dualMinutes += ft.dual;
      nightMinutes += ft.night;
      ifrMinutes += ft.ifr;

      dayLandings += flight.landings.day;
      nightLandings += flight.landings.night;

      // Categorize by aircraft type
      final category = AircraftCategorizer.categorize(flight.aircraftType);
      if (category == AircraftCategory.jet) {
        jetMinutes += ft.total;
      } else if (category == AircraftCategory.gaPiston) {
        gaPistonMinutes += ft.total;
      }
    }

    return ExperienceTotals(
      totalMinutes: totalMinutes,
      picMinutes: picMinutes,
      sicMinutes: sicMinutes,
      dualMinutes: dualMinutes,
      nightMinutes: nightMinutes,
      ifrMinutes: ifrMinutes,
      dayLandings: dayLandings,
      nightLandings: nightLandings,
      jetMinutes: jetMinutes,
      gaPistonMinutes: gaPistonMinutes,
    );
  }

  /// Format minutes as HH:MM
  static String formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours:${mins.toString().padLeft(2, '0')}';
  }

  // Formatted getters
  String get totalFormatted => formatMinutes(totalMinutes);
  String get picFormatted => formatMinutes(picMinutes);
  String get sicFormatted => formatMinutes(sicMinutes);
  String get dualFormatted => formatMinutes(dualMinutes);
  String get nightFormatted => formatMinutes(nightMinutes);
  String get ifrFormatted => formatMinutes(ifrMinutes);
  String get jetFormatted => formatMinutes(jetMinutes);
  String get gaPistonFormatted => formatMinutes(gaPistonMinutes);

  int get totalLandings => dayLandings + nightLandings;
}
