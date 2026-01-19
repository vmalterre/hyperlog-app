import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/aircraft_type.dart';
import '../services/aircraft_service.dart';
import '../services/api_exception.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Full-screen search page for adding aircraft types
/// Use this for + button actions (not field selection - use modal for that)
class AircraftTypeSearchScreen extends StatefulWidget {
  const AircraftTypeSearchScreen({super.key});

  /// Navigate to this screen and return the selected aircraft type
  static Future<AircraftType?> show(BuildContext context) {
    return Navigator.push<AircraftType>(
      context,
      MaterialPageRoute(
        builder: (context) => const AircraftTypeSearchScreen(),
      ),
    );
  }

  @override
  State<AircraftTypeSearchScreen> createState() =>
      _AircraftTypeSearchScreenState();
}

class _AircraftTypeSearchScreenState extends State<AircraftTypeSearchScreen> {
  final AircraftService _aircraftService = AircraftService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<AircraftType> _results = [];
  bool _isLoading = false;
  bool _hasError = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field
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
      final results =
          await _aircraftService.searchAircraftTypes(query, limit: 20);
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _results = [];
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _selectAircraftType(AircraftType type) {
    Navigator.of(context).pop(type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightRider,
      appBar: AppBar(
        backgroundColor: AppColors.nightRider,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Add Aircraft Type', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search A320, Boeing 737, C172...',
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
                fillColor: AppColors.nightRiderDark,
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

          // Results
          Expanded(
            child: _buildContent(),
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
                style:
                    AppTypography.body.copyWith(color: AppColors.whiteDarker),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _search(_searchController.text),
                child: Text(
                  'Retry',
                  style: AppTypography.button.copyWith(color: AppColors.denim),
                ),
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
                Icons.flight,
                color: AppColors.whiteDarker,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Search for an aircraft type',
                style:
                    AppTypography.body.copyWith(color: AppColors.whiteDarker),
              ),
              Text(
                'Enter ICAO code, manufacturer, or model',
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
                'No aircraft types found',
                style:
                    AppTypography.body.copyWith(color: AppColors.whiteDarker),
              ),
              Text(
                'Try a different search term',
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
        final type = _results[index];
        return _AircraftTypeResultTile(
          type: type,
          onTap: () => _selectAircraftType(type),
        );
      },
    );
  }
}

class _AircraftTypeResultTile extends StatelessWidget {
  final AircraftType type;
  final VoidCallback onTap;

  const _AircraftTypeResultTile({
    required this.type,
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
            // ICAO designator badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.denimBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                type.icaoDesignator,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.denimLight,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Manufacturer and model
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${type.manufacturer} ${type.model}',
                    style: AppTypography.body.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      _buildTag(type.engineType),
                      const SizedBox(width: 6),
                      _buildTag('${type.engineCount} eng'),
                      if (type.multiPilot == true) ...[
                        const SizedBox(width: 6),
                        _buildTag('Multi-Pilot'),
                      ],
                    ],
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

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.nightRider,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: AppColors.whiteDark,
          fontSize: 10,
        ),
      ),
    );
  }
}
