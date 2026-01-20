import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/airport_format.dart';
import '../../models/airport.dart';
import '../../services/preferences_service.dart';
import '../../theme/app_colors.dart';
import 'airport_search_modal.dart';

/// Autocomplete text field for airport selection
/// Opens a full-screen modal for search and selection
class AirportAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Airport? initialAirport;
  final void Function(Airport? airport) onAirportSelected;
  final String? Function(String?)? validator;

  const AirportAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = 'LHR',
    this.initialAirport,
    required this.onAirportSelected,
    this.validator,
  });

  @override
  State<AirportAutocompleteField> createState() =>
      AirportAutocompleteFieldState();
}

class AirportAutocompleteFieldState extends State<AirportAutocompleteField> {
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

  /// Select an airport programmatically (for AirportRouteFields compatibility)
  void selectAirport(Airport airport) {
    widget.controller.text = _getPreferredCode(airport);
    widget.onAirportSelected(airport);
  }

  Future<void> _openSearchModal() async {
    final result = await AirportSearchModal.show(
      context,
      title: widget.label,
      initialValue: widget.controller.text,
    );

    if (result == null) return;

    if (result.isAirport) {
      selectAirport(result.airport!);
    } else if (result.isManual) {
      widget.controller.text = result.manualEntry!;
      widget.onAirportSelected(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openSearchModal,
      child: AbsorbPointer(
        child: TextFormField(
          controller: widget.controller,
          readOnly: true,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
          ),
          validator: widget.validator,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            counterText: '',
            suffixIcon: Icon(
              Icons.search,
              color: AppColors.whiteDarker,
            ),
          ),
        ),
      ),
    );
  }
}
