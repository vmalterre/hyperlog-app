import '../models/logbook_entry.dart';

/// Page totals for a single page of the logbook
class PageTotals {
  int totalTime;
  int night;
  int ifr;
  int pic;
  int picus;
  int sic;
  int dual;
  int instructor;
  int multiEngine;
  int crossCountry;
  int dayLandings;
  int nightLandings;
  int dayTakeoffs;
  int nightTakeoffs;

  PageTotals({
    this.totalTime = 0,
    this.night = 0,
    this.ifr = 0,
    this.pic = 0,
    this.picus = 0,
    this.sic = 0,
    this.dual = 0,
    this.instructor = 0,
    this.multiEngine = 0,
    this.crossCountry = 0,
    this.dayLandings = 0,
    this.nightLandings = 0,
    this.dayTakeoffs = 0,
    this.nightTakeoffs = 0,
  });

  /// Add a flight entry to this page's totals
  void addEntry(LogbookEntry entry) {
    totalTime += entry.flightTime.total;
    night += entry.flightTime.night;
    ifr += entry.flightTime.ifr;
    pic += entry.flightTime.pic;
    picus += entry.flightTime.picus;
    sic += entry.flightTime.sic;
    dual += entry.flightTime.dual;
    instructor += entry.flightTime.instructor;
    multiEngine += entry.flightTime.multiEngine;
    crossCountry += entry.flightTime.crossCountry;

    final landings = entry.totalLandings;
    dayLandings += landings.day;
    nightLandings += landings.night;

    final takeoffs = entry.totalTakeoffs;
    dayTakeoffs += takeoffs.day;
    nightTakeoffs += takeoffs.night;
  }

  /// Create a copy of these totals
  PageTotals copy() {
    return PageTotals(
      totalTime: totalTime,
      night: night,
      ifr: ifr,
      pic: pic,
      picus: picus,
      sic: sic,
      dual: dual,
      instructor: instructor,
      multiEngine: multiEngine,
      crossCountry: crossCountry,
      dayLandings: dayLandings,
      nightLandings: nightLandings,
      dayTakeoffs: dayTakeoffs,
      nightTakeoffs: nightTakeoffs,
    );
  }

  int get totalLandings => dayLandings + nightLandings;
  int get totalTakeoffs => dayTakeoffs + nightTakeoffs;
}

/// Cumulative totals running through all pages
class CumulativeTotals {
  final PageTotals _totals = PageTotals();

  /// Add a page's totals to the cumulative total
  void addPageTotals(PageTotals page) {
    _totals.totalTime += page.totalTime;
    _totals.night += page.night;
    _totals.ifr += page.ifr;
    _totals.pic += page.pic;
    _totals.picus += page.picus;
    _totals.sic += page.sic;
    _totals.dual += page.dual;
    _totals.instructor += page.instructor;
    _totals.multiEngine += page.multiEngine;
    _totals.crossCountry += page.crossCountry;
    _totals.dayLandings += page.dayLandings;
    _totals.nightLandings += page.nightLandings;
    _totals.dayTakeoffs += page.dayTakeoffs;
    _totals.nightTakeoffs += page.nightTakeoffs;
  }

  /// Get current cumulative totals (returns a copy)
  PageTotals get totals => _totals.copy();
}

/// Utility functions for PDF formatting
class PdfFormatUtils {
  /// Format minutes as HH:MM (e.g., 90 -> "01:30")
  static String formatMinutesAsHHMM(int minutes) {
    if (minutes == 0) return '';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  /// Format minutes as decimal hours (e.g., 90 -> "1.5")
  static String formatMinutesAsDecimal(int minutes) {
    if (minutes == 0) return '';
    final hours = minutes / 60;
    return hours.toStringAsFixed(1);
  }

  /// Format time of day (e.g., DateTime -> "14:30")
  static String formatTimeOfDay(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Format date as DD/MM/YY (EASA standard)
  static String formatDateDDMMYY(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${(date.year % 100).toString().padLeft(2, '0')}';
  }

  /// Format date as MM/DD/YY (FAA standard)
  static String formatDateMMDDYY(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${(date.year % 100).toString().padLeft(2, '0')}';
  }

  /// Format date as DD-MM-YYYY (UK standard)
  static String formatDateDDMMYYYY(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  /// Format date as YYYY-MM-DD (ISO standard)
  static String formatDateISO(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Format integer, empty string if zero
  static String formatInt(int value) {
    return value == 0 ? '' : value.toString();
  }

  /// Get PIC name from entry (creator if PIC, or first PIC from crew)
  static String getPicName(LogbookEntry entry) {
    final creator = entry.creatorCrew;
    if (creator != null) {
      final isPic = creator.primaryRole.toUpperCase() == 'PIC';
      if (isPic) {
        return creator.pilotName ?? '—';
      }
    }

    // Look for PIC in other crew members
    for (final crew in entry.crew) {
      if (crew.primaryRole.toUpperCase() == 'PIC') {
        return crew.pilotName ?? '—';
      }
    }

    return '—';
  }

  /// Get remarks from creator's crew entry
  static String getRemarks(LogbookEntry entry) {
    return entry.creatorCrew?.remarks ?? '';
  }
}
