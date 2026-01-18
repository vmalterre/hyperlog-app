import 'package:flutter/material.dart';
import '../../models/airport.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'airport_autocomplete_field.dart';

/// Combined From/To airport fields with a shared dropdown spanning both fields
class AirportRouteFields extends StatefulWidget {
  final TextEditingController depController;
  final TextEditingController destController;
  final Airport? initialDepAirport;
  final Airport? initialDestAirport;
  final void Function(Airport? airport) onDepAirportSelected;
  final void Function(Airport? airport) onDestAirportSelected;
  final String? Function(String?)? depValidator;
  final String? Function(String?)? destValidator;
  final GlobalKey? depKey;
  final GlobalKey? destKey;

  const AirportRouteFields({
    super.key,
    required this.depController,
    required this.destController,
    this.initialDepAirport,
    this.initialDestAirport,
    required this.onDepAirportSelected,
    required this.onDestAirportSelected,
    this.depValidator,
    this.destValidator,
    this.depKey,
    this.destKey,
  });

  @override
  State<AirportRouteFields> createState() => _AirportRouteFieldsState();
}

class _AirportRouteFieldsState extends State<AirportRouteFields> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey<AirportAutocompleteFieldState> _depFieldKey = GlobalKey();
  final GlobalKey<AirportAutocompleteFieldState> _destFieldKey = GlobalKey();

  OverlayEntry? _overlayEntry;
  List<Airport> _suggestions = [];
  bool _isLoading = false;
  bool _hasError = false;
  bool _isDepFieldActive = true; // Track which field is active

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _onSearchResults(List<Airport> results, bool isLoading, bool hasError, bool isDepField) {
    if (!mounted) return;

    setState(() {
      _suggestions = results;
      _isLoading = isLoading;
      _hasError = hasError;
      _isDepFieldActive = isDepField;
    });

    // Show or hide overlay based on focus state
    final depHasFocus = _depFieldKey.currentState?.hasFocus ?? false;
    final destHasFocus = _destFieldKey.currentState?.hasFocus ?? false;

    if (depHasFocus || destHasFocus) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    final depHasFocus = _depFieldKey.currentState?.hasFocus ?? false;
    final destHasFocus = _destFieldKey.currentState?.hasFocus ?? false;

    if (!depHasFocus && !destHasFocus) return;

    // Get the row width after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final RenderBox? box = context.findRenderObject() as RenderBox?;
      if (box == null) return;

      final rowWidth = box.size.width;

      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          width: rowWidth,
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
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
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
          onTap: () => _selectAirport(airport),
        );
      },
    );
  }

  void _selectAirport(Airport airport) {
    if (_isDepFieldActive) {
      _depFieldKey.currentState?.selectAirport(airport);
    } else {
      _destFieldKey.currentState?.selectAirport(airport);
    }
    _removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Row(
        children: [
          Expanded(
            key: widget.depKey,
            child: AirportAutocompleteField(
              key: _depFieldKey,
              controller: widget.depController,
              label: 'From',
              hint: 'LHR',
              initialAirport: widget.initialDepAirport,
              validator: widget.depValidator,
              showOwnDropdown: false,
              sharedLayerLink: _layerLink,
              onAirportSelected: widget.onDepAirportSelected,
              onSearchResults: (results, isLoading, hasError) {
                _onSearchResults(results, isLoading, hasError, true);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              Icons.arrow_forward,
              color: AppColors.denimLight,
              size: 24,
            ),
          ),
          Expanded(
            key: widget.destKey,
            child: AirportAutocompleteField(
              key: _destFieldKey,
              controller: widget.destController,
              label: 'To',
              hint: 'JFK',
              initialAirport: widget.initialDestAirport,
              validator: widget.destValidator,
              showOwnDropdown: false,
              sharedLayerLink: _layerLink,
              onAirportSelected: widget.onDestAirportSelected,
              onSearchResults: (results, isLoading, hasError) {
                _onSearchResults(results, isLoading, hasError, false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
