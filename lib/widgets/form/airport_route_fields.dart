import 'package:flutter/material.dart';
import '../../models/airport.dart';
import '../../theme/app_colors.dart';
import 'airport_autocomplete_field.dart';

/// Combined From/To airport fields with arrow between them
/// Each field opens its own modal for airport selection
class AirportRouteFields extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          key: depKey,
          child: AirportAutocompleteField(
            controller: depController,
            label: 'From',
            hint: 'LHR',
            initialAirport: initialDepAirport,
            validator: depValidator,
            onAirportSelected: onDepAirportSelected,
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
          key: destKey,
          child: AirportAutocompleteField(
            controller: destController,
            label: 'To',
            hint: 'JFK',
            initialAirport: initialDestAirport,
            validator: destValidator,
            onAirportSelected: onDestAirportSelected,
          ),
        ),
      ],
    );
  }
}
