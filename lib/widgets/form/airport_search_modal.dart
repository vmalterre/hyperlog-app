import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/airport.dart';
import '../../services/airport_service.dart';
import '../../services/api_exception.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Result from airport search modal - either an Airport or manual entry string
class AirportSearchResult {
  final Airport? airport;
  final String? manualEntry;

  AirportSearchResult.airport(this.airport) : manualEntry = null;
  AirportSearchResult.manual(this.manualEntry) : airport = null;

  bool get isAirport => airport != null;
  bool get isManual => manualEntry != null;
}

/// Full-screen modal for airport search and selection
/// Opens above the keyboard with search input and scrollable results
class AirportSearchModal extends StatefulWidget {
  final String title;
  final String? initialValue;

  const AirportSearchModal({
    super.key,
    required this.title,
    this.initialValue,
  });

  /// Show the modal and return the selected airport or manual entry
  static Future<AirportSearchResult?> show(
    BuildContext context, {
    required String title,
    String? initialValue,
  }) {
    return showModalBottomSheet<AirportSearchResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AirportSearchModal(
        title: title,
        initialValue: initialValue,
      ),
    );
  }

  @override
  State<AirportSearchModal> createState() => _AirportSearchModalState();
}

class _AirportSearchModalState extends State<AirportSearchModal> {
  final AirportService _airportService = AirportService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Airport> _results = [];
  bool _isLoading = false;
  bool _hasError = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _searchController.text = widget.initialValue!;
      _search(widget.initialValue!);
    }
    // Auto-focus the search field after modal animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    if (value.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
        _hasError = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _search(value);
    });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final results = await _airportService.search(query, limit: 15);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
          _hasError = false;
        });
      }
    } on ApiException {
      if (mounted) {
        setState(() {
          _results = [];
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _selectAirport(Airport airport) {
    Navigator.of(context).pop(AirportSearchResult.airport(airport));
  }

  void _useManualEntry() {
    final text = _searchController.text.trim().toUpperCase();
    if (text.isNotEmpty) {
      Navigator.of(context).pop(AirportSearchResult.manual(text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.nightRiderDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.whiteDarker,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: AppTypography.h4,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: AppColors.whiteDarker),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
              inputFormatters: [_UpperCaseFormatter()],
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search ICAO, IATA, or name...',
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.whiteDarker,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.whiteDarker,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        icon: Icon(Icons.clear, color: AppColors.whiteDarker),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.nightRider,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderVisible),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderVisible),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.denim, width: 2),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Results list
          Expanded(
            child: _buildContent(),
          ),

          // Manual entry option
          if (_searchController.text.isNotEmpty && !_isLoading)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.borderVisible),
                ),
              ),
              child: SafeArea(
                top: false,
                child: InkWell(
                  onTap: _useManualEntry,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.denimBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.denimBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: AppColors.denimLight,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Use "${_searchController.text.toUpperCase()}"',
                                style: AppTypography.body.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Enter manually if not found',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.whiteDarker,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.denimLight,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.denim),
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off,
                color: AppColors.whiteDarker,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Search failed',
                style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
              ),
              Text(
                'You can enter the code manually below',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.flight_takeoff,
                color: AppColors.whiteDarker,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Search for an airport',
                style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
              ),
              Text(
                'Enter ICAO, IATA, or airport name',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                color: AppColors.whiteDarker,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'No airports found',
                style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
              ),
              Text(
                'Try a different search or enter manually',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final airport = _results[index];
        return _AirportResultTile(
          airport: airport,
          onTap: () => _selectAirport(airport),
        );
      },
    );
  }
}

class _AirportResultTile extends StatelessWidget {
  final Airport airport;
  final VoidCallback onTap;

  const _AirportResultTile({
    required this.airport,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glassDark50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            // Airport codes
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.denimBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                airport.codeDisplay,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.denimLight,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Airport name and location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    airport.name,
                    style: AppTypography.body.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (airport.municipality != null || airport.isoCountry != null)
                    Text(
                      [airport.municipality, airport.isoCountry]
                          .where((s) => s != null)
                          .join(', '),
                      style: AppTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.whiteDarker,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Uppercase input formatter
class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
