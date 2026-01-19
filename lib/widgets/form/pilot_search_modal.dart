import 'package:flutter/material.dart';
import '../../models/saved_pilot.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Result from pilot search modal - either a SavedPilot or new name string
class PilotSearchResult {
  final SavedPilot? pilot;
  final String? newName;

  PilotSearchResult.pilot(this.pilot) : newName = null;
  PilotSearchResult.newPilot(this.newName) : pilot = null;

  bool get isSavedPilot => pilot != null;
  bool get isNewPilot => newName != null;

  String get name => pilot?.name ?? newName ?? '';
}

/// Full-screen modal for pilot search and selection
/// Opens above the keyboard with search input and scrollable results
class PilotSearchModal extends StatefulWidget {
  final String title;
  final String? initialValue;
  final List<SavedPilot> savedPilots;

  const PilotSearchModal({
    super.key,
    required this.title,
    required this.savedPilots,
    this.initialValue,
  });

  /// Show the modal and return the selected pilot or new name
  static Future<PilotSearchResult?> show(
    BuildContext context, {
    required String title,
    required List<SavedPilot> savedPilots,
    String? initialValue,
  }) {
    return showModalBottomSheet<PilotSearchResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PilotSearchModal(
        title: title,
        savedPilots: savedPilots,
        initialValue: initialValue,
      ),
    );
  }

  @override
  State<PilotSearchModal> createState() => _PilotSearchModalState();
}

class _PilotSearchModalState extends State<PilotSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<SavedPilot> _filteredPilots = [];

  @override
  void initState() {
    super.initState();
    _filteredPilots = widget.savedPilots;
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _searchController.text = widget.initialValue!;
      _filterPilots(widget.initialValue!);
    }
    // Auto-focus the search field after modal animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterPilots(String query) {
    if (query.isEmpty) {
      setState(() => _filteredPilots = widget.savedPilots);
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredPilots = widget.savedPilots
          .where((pilot) => pilot.name.toLowerCase().contains(lowerQuery))
          .toList();
    });
  }

  void _selectPilot(SavedPilot pilot) {
    Navigator.of(context).pop(PilotSearchResult.pilot(pilot));
  }

  void _addNewPilot() {
    final name = _searchController.text.trim();
    if (name.isNotEmpty) {
      Navigator.of(context).pop(PilotSearchResult.newPilot(name));
    }
  }

  bool _isExactMatch() {
    final query = _searchController.text.trim().toLowerCase();
    return widget.savedPilots.any(
      (pilot) => pilot.name.toLowerCase() == query,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final showAddNew = _searchController.text.isNotEmpty && !_isExactMatch();

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
              textCapitalization: TextCapitalization.words,
              style: AppTypography.body.copyWith(color: AppColors.white),
              onChanged: _filterPilots,
              decoration: InputDecoration(
                hintText: 'Search or enter new name...',
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
                          _filterPilots('');
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

          // Add new pilot option
          if (showAddNew)
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
                  onTap: _addNewPilot,
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
                          Icons.person_add_outlined,
                          color: AppColors.denimLight,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add "${_searchController.text.trim()}"',
                                style: AppTypography.body.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Add new pilot to your crew list',
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
    if (_searchController.text.isEmpty && widget.savedPilots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline,
                color: AppColors.whiteDarker,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'No saved pilots yet',
                style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
              ),
              Text(
                'Type a name to add a new pilot',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: widget.savedPilots.length,
        itemBuilder: (context, index) {
          final pilot = widget.savedPilots[index];
          return _PilotResultTile(
            pilot: pilot,
            onTap: () => _selectPilot(pilot),
          );
        },
      );
    }

    if (_filteredPilots.isEmpty) {
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
                'No matching pilots',
                style: AppTypography.body.copyWith(color: AppColors.whiteDarker),
              ),
              Text(
                'Add this person as a new pilot below',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredPilots.length,
      itemBuilder: (context, index) {
        final pilot = _filteredPilots[index];
        return _PilotResultTile(
          pilot: pilot,
          onTap: () => _selectPilot(pilot),
        );
      },
    );
  }
}

class _PilotResultTile extends StatelessWidget {
  final SavedPilot pilot;
  final VoidCallback onTap;

  const _PilotResultTile({
    required this.pilot,
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
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.denimBg,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(
                  _getInitials(pilot.name),
                  style: AppTypography.body.copyWith(
                    color: AppColors.denimLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name and flight count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pilot.name,
                    style: AppTypography.body.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (pilot.flightCount > 0)
                    Text(
                      '${pilot.flightCount} flight${pilot.flightCount == 1 ? '' : 's'} together',
                      style: AppTypography.caption,
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

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
