import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/export_format.dart';
import '../models/logbook_entry.dart';
import '../services/flight_service.dart';
import '../services/pdf_export_service.dart';
import '../session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_button.dart';
import '../widgets/glass_card.dart';

class ExportLogbookScreen extends StatefulWidget {
  const ExportLogbookScreen({super.key});

  @override
  State<ExportLogbookScreen> createState() => _ExportLogbookScreenState();
}

class _ExportLogbookScreenState extends State<ExportLogbookScreen> {
  LogbookExportFormat _selectedFormat = LogbookExportFormat.international;
  DateTime? _startDate;
  DateTime? _endDate;

  List<LogbookEntry>? _flights;
  bool _isLoading = true;
  bool _isExporting = false;
  String? _error;

  final _flightService = FlightService();
  final _pdfService = PdfExportService();

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  Future<void> _loadFlights() async {
    final session = Provider.of<SessionState>(context, listen: false);
    final userId = session.currentPilot?.id;

    if (userId == null) {
      setState(() {
        _isLoading = false;
        _error = 'No user logged in';
      });
      return;
    }

    try {
      final flights = await _flightService.getFullFlightsForUser(userId);
      if (mounted) {
        setState(() {
          _flights = flights;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load flights: $e';
        });
      }
    }
  }

  int get _filteredFlightCount {
    if (_flights == null) return 0;
    return _pdfService.getFilteredFlightCount(
      flights: _flights!,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  Future<void> _exportPdf() async {
    if (_flights == null || _flights!.isEmpty) return;

    final session = Provider.of<SessionState>(context, listen: false);
    final pilot = session.currentPilot;
    if (pilot == null) return;

    setState(() {
      _isExporting = true;
    });

    try {
      await _pdfService.exportAndShare(
        flights: _flights!,
        format: _selectedFormat,
        pilotName: pilot.displayName,
        licenseNumber: pilot.licenseNumber,
        startDate: _startDate,
        endDate: _endDate,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final initial = isStart ? _startDate : _endDate;
    final firstDate = DateTime(2000);
    final lastDate = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.denim,
              surface: AppColors.nightRiderDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Ensure end date is not before start date
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _clearDateRange() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightRider,
      appBar: AppBar(
        backgroundColor: AppColors.nightRider,
        elevation: 0,
        title: Text('Export Logbook', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.denim),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      style: AppTypography.body.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Format section
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 12),
                        child: Text('FORMAT', style: AppTypography.label),
                      ),
                      GlassContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose the logbook format for your PDF export.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.whiteDarker,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...LogbookExportFormat.values.map((format) =>
                                _FormatOption(
                                  format: format,
                                  isSelected: _selectedFormat == format,
                                  onTap: () {
                                    setState(() {
                                      _selectedFormat = format;
                                    });
                                  },
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Date range section
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 12),
                        child: Text('DATE RANGE (OPTIONAL)', style: AppTypography.label),
                      ),
                      GlassContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filter flights by date range. Leave empty to export all flights.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.whiteDarker,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _DateField(
                                    label: 'From',
                                    date: _startDate,
                                    onTap: () => _selectDate(true),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _DateField(
                                    label: 'To',
                                    date: _endDate,
                                    onTap: () => _selectDate(false),
                                  ),
                                ),
                                if (_startDate != null || _endDate != null) ...[
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: const Icon(Icons.clear, color: AppColors.whiteDarker),
                                    onPressed: _clearDateRange,
                                    tooltip: 'Clear dates',
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Flight count preview
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.flight,
                              size: 20,
                              color: _filteredFlightCount > 0
                                  ? AppColors.denim
                                  : AppColors.whiteDarker,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _filteredFlightCount == 0
                                  ? 'No flights to export'
                                  : _filteredFlightCount == 1
                                      ? '1 flight will be exported'
                                      : '$_filteredFlightCount flights will be exported',
                              style: AppTypography.body.copyWith(
                                color: _filteredFlightCount > 0
                                    ? AppColors.white
                                    : AppColors.whiteDarker,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Export button
                      PrimaryButton(
                        label: 'Export PDF',
                        icon: Icons.picture_as_pdf,
                        fullWidth: true,
                        isLoading: _isExporting,
                        onPressed: _filteredFlightCount > 0 ? _exportPdf : null,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}

class _FormatOption extends StatelessWidget {
  final LogbookExportFormat format;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatOption({
    required this.format,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final info = ExportFormats.getInfo(format);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              // Radio indicator
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.denim : AppColors.whiteDarker,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.denim,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Format name and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.displayName,
                      style: AppTypography.body.copyWith(
                        color: AppColors.white,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      info.description,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderSubtle),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: AppColors.whiteDarker,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null ? dateFormat.format(date!) : label,
                style: AppTypography.bodySmall.copyWith(
                  color: date != null ? AppColors.white : AppColors.whiteDarker,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
