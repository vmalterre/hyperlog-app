import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/airport_format.dart';
import '../../models/airport.dart';
import '../../services/airport_service.dart';
import '../../services/api_exception.dart';
import '../../services/preferences_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Autocomplete text field for airport selection
/// Searches by ICAO (4 letters), IATA (3 letters), or airport name
/// Allows raw input for unknown airfields
class AirportAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Airport? initialAirport;
  final void Function(Airport? airport) onAirportSelected;
  final String? Function(String?)? validator;
  /// Optional: provide a LayerLink to position dropdown relative to a parent widget
  final LayerLink? sharedLayerLink;
  /// Optional: custom dropdown width (defaults to field width)
  final double? dropdownWidth;
  /// Optional: callback when search results are available (for shared dropdown)
  final void Function(List<Airport> results, bool isLoading, bool hasError)? onSearchResults;
  /// If true, this field manages its own dropdown. If false, parent manages dropdown.
  final bool showOwnDropdown;

  const AirportAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = 'LHR',
    this.initialAirport,
    required this.onAirportSelected,
    this.validator,
    this.sharedLayerLink,
    this.dropdownWidth,
    this.onSearchResults,
    this.showOwnDropdown = true,
  });

  @override
  State<AirportAutocompleteField> createState() =>
      AirportAutocompleteFieldState();
}

class AirportAutocompleteFieldState extends State<AirportAutocompleteField> {
  final AirportService _airportService = AirportService();
  late final LayerLink _layerLink;
  final FocusNode _focusNode = FocusNode();

  OverlayEntry? _overlayEntry;
  List<Airport> _suggestions = [];
  bool _isLoading = false;
  bool _hasError = false;
  Timer? _debounceTimer;
  Airport? _selectedAirport;

  FocusNode get focusNode => _focusNode;
  bool get hasFocus => _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _layerLink = widget.sharedLayerLink ?? LayerLink();
    _selectedAirport = widget.initialAirport;
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Show dropdown when focused with existing text
      if (widget.controller.text.isNotEmpty) {
        _search(widget.controller.text);
      }
    } else {
      // Delay hiding to allow tap on dropdown
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!_focusNode.hasFocus) {
          _removeOverlay();
          // Notify parent that focus is lost (to hide shared dropdown)
          widget.onSearchResults?.call([], false, false);
        }
      });
    }
  }

  void _onTextChanged() {
    final text = widget.controller.text;

    // Clear selection if user modifies text
    if (_selectedAirport != null) {
      final preferredCode = _getPreferredCode(_selectedAirport!);
      if (text != preferredCode) {
        _selectedAirport = null;
        widget.onAirportSelected(null);
      } else {
        // Text matches selected airport - don't search again
        _debounceTimer?.cancel();
        return;
      }
    }

    // Debounce search
    _debounceTimer?.cancel();
    if (text.isEmpty) {
      _removeOverlay();
      widget.onSearchResults?.call([], false, false);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _search(text);
    });
  }

  /// Get the preferred airport code based on user settings
  String _getPreferredCode(Airport airport) {
    final format = PreferencesService.instance.getAirportCodeFormat();
    return AirportFormats.formatCode(
      icaoCode: airport.icaoCode,
      iataCode: airport.iataCode,
      fallbackCode: airport.ident,
      format: format,
    );
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      _removeOverlay();
      widget.onSearchResults?.call([], false, false);
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    widget.onSearchResults?.call(_suggestions, true, false);

    try {
      final results = await _airportService.search(query, limit: 10);
      if (mounted && _focusNode.hasFocus) {
        setState(() {
          _suggestions = results;
          _isLoading = false;
        });
        widget.onSearchResults?.call(results, false, false);
        if (widget.showOwnDropdown) {
          _showOverlay();
        }
      }
    } on ApiException {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _suggestions = [];
        });
        widget.onSearchResults?.call([], false, true);
        if (widget.showOwnDropdown) {
          _showOverlay();
        }
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();

    if (!_focusNode.hasFocus) return;

    final dropdownWidth = widget.dropdownWidth ?? _getFieldWidth();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: dropdownWidth,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            elevation: 8,
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: AppColors.nightRiderDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderVisible,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildDropdownContent(),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double _getFieldWidth() {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    return box?.size.width ?? 200;
  }

  Widget _buildDropdownContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.denim),
            ),
          ),
        ),
      );
    }

    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Search failed. Manual entry allowed.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.whiteDarker,
          ),
        ),
      );
    }

    if (_suggestions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No airports found',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.whiteDarker,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final airport = _suggestions[index];
        return AirportListItem(
          airport: airport,
          onTap: () => selectAirport(airport),
        );
      },
    );
  }

  /// Select an airport (can be called externally for shared dropdown)
  void selectAirport(Airport airport) {
    setState(() {
      _selectedAirport = airport;
      _isLoading = false;
    });
    widget.controller.text = _getPreferredCode(airport);
    widget.onAirportSelected(airport);
    _removeOverlay();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final textField = TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      textCapitalization: TextCapitalization.characters,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      validator: widget.validator,
      inputFormatters: [
        UpperCaseFormatter(),
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        counterText: '',
        suffixIcon: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.denim),
                  ),
                ),
              )
            : null,
      ),
    );

    if (widget.sharedLayerLink != null) {
      return textField;
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: textField,
    );
  }
}

/// Individual airport item in the dropdown
class AirportListItem extends StatelessWidget {
  final Airport airport;
  final VoidCallback onTap;

  const AirportListItem({
    super.key,
    required this.airport,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.borderSubtle,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              airport.codeDisplay,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.denimLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              airport.displayLabel,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.whiteDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Uppercase input formatter
class UpperCaseFormatter extends TextInputFormatter {
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
