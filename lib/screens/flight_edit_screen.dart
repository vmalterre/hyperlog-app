import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/logbook_entry.dart';
import '../services/flight_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/app_button.dart';
import '../widgets/glass_card.dart';

class FlightEditScreen extends StatefulWidget {
  final LogbookEntry entry;

  const FlightEditScreen({
    super.key,
    required this.entry,
  });

  @override
  State<FlightEditScreen> createState() => _FlightEditScreenState();
}

class _FlightEditScreenState extends State<FlightEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final FlightService _flightService = FlightService();

  late TextEditingController _flightNumberController;
  late TextEditingController _depController;
  late TextEditingController _destController;
  late TextEditingController _aircraftTypeController;
  late TextEditingController _aircraftRegController;
  late TextEditingController _roleController;
  late TextEditingController _remarksController;
  late TextEditingController _flightTimeController;
  late TextEditingController _landingsController;

  late DateTime _flightDate;
  late DateTime _blockOff;
  late DateTime _blockOn;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _flightNumberController = TextEditingController(text: widget.entry.flightNumber ?? '');
    _depController = TextEditingController(text: widget.entry.dep);
    _destController = TextEditingController(text: widget.entry.dest);
    _aircraftTypeController = TextEditingController(text: widget.entry.aircraftType);
    _aircraftRegController = TextEditingController(text: widget.entry.aircraftReg);
    _roleController = TextEditingController(text: widget.entry.role);
    _remarksController = TextEditingController(text: widget.entry.remarks ?? '');
    _flightTimeController = TextEditingController(text: widget.entry.flightTime.total.toString());
    _landingsController = TextEditingController(text: widget.entry.landings.total.toString());

    _flightDate = widget.entry.flightDate;
    _blockOff = widget.entry.blockOff;
    _blockOn = widget.entry.blockOn;
  }

  @override
  void dispose() {
    _flightNumberController.dispose();
    _depController.dispose();
    _destController.dispose();
    _aircraftTypeController.dispose();
    _aircraftRegController.dispose();
    _roleController.dispose();
    _remarksController.dispose();
    _flightTimeController.dispose();
    _landingsController.dispose();
    super.dispose();
  }

  LogbookEntry _buildUpdatedEntry() {
    final flightTimeMinutes = int.tryParse(_flightTimeController.text) ?? widget.entry.flightTime.total;
    final landingsTotal = int.tryParse(_landingsController.text) ?? widget.entry.landings.total;

    return LogbookEntry(
      id: widget.entry.id,
      pilotLicense: widget.entry.pilotLicense,
      flightDate: _flightDate,
      flightNumber: _flightNumberController.text.isEmpty ? null : _flightNumberController.text,
      dep: _depController.text.toUpperCase(),
      dest: _destController.text.toUpperCase(),
      blockOff: _blockOff,
      blockOn: _blockOn,
      aircraftType: _aircraftTypeController.text.toUpperCase(),
      aircraftReg: _aircraftRegController.text.toUpperCase(),
      flightTime: FlightTime(
        total: flightTimeMinutes,
        night: widget.entry.flightTime.night,
        ifr: widget.entry.flightTime.ifr,
        pic: widget.entry.flightTime.pic,
        sic: widget.entry.flightTime.sic,
        dual: widget.entry.flightTime.dual,
      ),
      landings: Landings(
        day: landingsTotal,
        night: widget.entry.landings.night,
      ),
      role: _roleController.text.toUpperCase(),
      remarks: _remarksController.text.isEmpty ? null : _remarksController.text,
      trustLevel: widget.entry.trustLevel,
      createdAt: widget.entry.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updatedEntry = _buildUpdatedEntry();
      final result = await _flightService.updateFlight(widget.entry.id, updatedEntry);

      if (mounted) {
        Navigator.pop(context, result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _flightDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.denim,
              surface: AppColors.nightRiderDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _flightDate = picked);
    }
  }

  Future<void> _selectTime(bool isBlockOff) async {
    final currentTime = isBlockOff ? _blockOff : _blockOn;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentTime),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.denim,
              surface: AppColors.nightRiderDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final newTime = DateTime(
          _flightDate.year,
          _flightDate.month,
          _flightDate.day,
          picked.hour,
          picked.minute,
        );
        if (isBlockOff) {
          _blockOff = newTime;
        } else {
          _blockOn = newTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: AppColors.nightRiderDark,
      appBar: AppBar(
        title: Text('Amend Flight', style: AppTypography.h4),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date picker
            GlassContainer(
              child: InkWell(
                onTap: _selectDate,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Flight Date', style: AppTypography.body.copyWith(color: AppColors.whiteDarker)),
                    Row(
                      children: [
                        Text(
                          dateFormat.format(_flightDate),
                          style: AppTypography.body.copyWith(color: AppColors.white),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today, size: 18, color: AppColors.denim),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Route
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Route', style: AppTypography.body.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('From', _depController, maxLength: 4)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('To', _destController, maxLength: 4)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Times
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Times', style: AppTypography.body.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimePicker('Block Off', timeFormat.format(_blockOff), () => _selectTime(true)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimePicker('Block On', timeFormat.format(_blockOn), () => _selectTime(false)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField('Flight Time (min)', _flightTimeController, isNumeric: true),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Aircraft
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aircraft', style: AppTypography.body.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Type', _aircraftTypeController)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Registration', _aircraftRegController)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Flight details
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Details', style: AppTypography.body.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  _buildTextField('Flight Number', _flightNumberController),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Role', _roleController)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Landings', _landingsController, isNumeric: true)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField('Remarks', _remarksController, maxLines: 3),
                ],
              ),
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              label: _isSaving ? 'Saving...' : 'Save Changes',
              onPressed: _isSaving ? null : _saveChanges,
              icon: Icons.save,
              fullWidth: true,
              isLoading: _isSaving,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumeric = false,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      maxLength: maxLength,
      style: AppTypography.body.copyWith(color: AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.body.copyWith(color: AppColors.whiteDarker),
        counterText: '',
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderVisible),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.denim),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (isNumeric && value != null && value.isNotEmpty) {
          if (int.tryParse(value) == null) {
            return 'Enter a valid number';
          }
        }
        return null;
      },
    );
  }

  Widget _buildTimePicker(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderVisible),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.caption.copyWith(color: AppColors.whiteDarker)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: AppTypography.body.copyWith(color: AppColors.white)),
                const Icon(Icons.access_time, size: 18, color: AppColors.denim),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
