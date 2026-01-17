import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Styled text input with glass container background
class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final String? suffixText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final int maxLines;
  final bool monospace;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  const GlassTextField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixText,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.maxLines = 1,
    this.monospace = false,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = monospace
        ? GoogleFonts.jetBrainsMono(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
          )
        : AppTypography.body.copyWith(color: AppColors.white);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      maxLines: maxLines,
      style: textStyle,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '', // Hide the counter
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.whiteDarker, size: 20)
            : null,
        suffixText: suffixText,
        suffixStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.whiteDarker,
        ),
      ),
    );
  }
}

/// Uppercase input formatter for IATA codes
class UpperCaseTextFormatter extends TextInputFormatter {
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

/// Letters only input formatter
class LettersOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final filtered = newValue.text.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

/// Alphanumeric and hyphen formatter for aircraft registration
class AircraftRegFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final filtered = newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9-]'), '');
    return TextEditingValue(
      text: filtered.toUpperCase(),
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}
