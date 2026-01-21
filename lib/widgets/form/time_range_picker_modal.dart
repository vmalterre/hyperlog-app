import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/logbook_entry.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Modal for selecting a time range with two draggable thumbs
///
/// Returns the selected duration in minutes (end - start).
/// The visual bar represents the full block time (blockOff to blockOn).
class TimeRangePickerModal extends StatefulWidget {
  final String title;
  final int totalMinutes;
  final int initialDuration;
  final TimeOfDay? blockOff;
  final TimeOfDay? blockOn;

  const TimeRangePickerModal({
    super.key,
    required this.title,
    required this.totalMinutes,
    required this.initialDuration,
    this.blockOff,
    this.blockOn,
  });

  /// Show the modal and return the selected duration in minutes
  static Future<int?> show(
    BuildContext context, {
    required String title,
    required int totalMinutes,
    required int initialDuration,
    TimeOfDay? blockOff,
    TimeOfDay? blockOn,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TimeRangePickerModal(
        title: title,
        totalMinutes: totalMinutes,
        initialDuration: initialDuration,
        blockOff: blockOff,
        blockOn: blockOn,
      ),
    );
  }

  @override
  State<TimeRangePickerModal> createState() => _TimeRangePickerModalState();
}

class _TimeRangePickerModalState extends State<TimeRangePickerModal> {
  late int _startMinutes; // Offset from block off
  late int _endMinutes; // Offset from block off

  static const int _stepSize = 5;
  static const double _thumbSize = 28.0;
  static const double _trackHeight = 6.0;

  @override
  void initState() {
    super.initState();
    // Initialize with selection starting at 0, ending at initialDuration
    _startMinutes = 0;
    _endMinutes = widget.initialDuration.clamp(0, widget.totalMinutes);
  }

  int get _duration => _endMinutes - _startMinutes;

  String _formatTimeOffset(int offsetMinutes) {
    if (widget.blockOff == null) {
      // Just show offset as HH:MM
      return FlightTime.formatMinutes(offsetMinutes);
    }

    // Calculate actual time by adding offset to blockOff
    final totalMinutes = widget.blockOff!.hour * 60 + widget.blockOff!.minute + offsetMinutes;
    final hours = (totalMinutes ~/ 60) % 24;
    final mins = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  void _handleConfirm() {
    Navigator.of(context).pop(_duration);
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.nightRiderDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text(widget.title, style: AppTypography.h4),
                  const Spacer(),
                  IconButton(
                    onPressed: _handleCancel,
                    icon: Icon(Icons.close, color: AppColors.whiteDarker),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Time labels above track
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTimeOffset(0),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.whiteDarker,
                    ),
                  ),
                  Text(
                    _formatTimeOffset(widget.totalMinutes),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.whiteDarker,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Time range slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _TimeRangeSlider(
                totalMinutes: widget.totalMinutes,
                startMinutes: _startMinutes,
                endMinutes: _endMinutes,
                thumbSize: _thumbSize,
                trackHeight: _trackHeight,
                stepSize: _stepSize,
                onStartChanged: (value) {
                  if (value != _startMinutes && value < _endMinutes) {
                    HapticFeedback.selectionClick();
                    setState(() => _startMinutes = value);
                  }
                },
                onEndChanged: (value) {
                  if (value != _endMinutes && value > _startMinutes) {
                    HapticFeedback.selectionClick();
                    setState(() => _endMinutes = value);
                  }
                },
              ),
            ),

            const SizedBox(height: 24),

            // Selected range display
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.denimBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.denimBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Start time
                  Column(
                    children: [
                      Text(
                        'Start',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.whiteDarker,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimeOffset(_startMinutes),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),

                  // Separator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(
                      Icons.arrow_forward,
                      color: AppColors.denimLight,
                      size: 24,
                    ),
                  ),

                  // End time
                  Column(
                    children: [
                      Text(
                        'End',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.whiteDarker,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimeOffset(_endMinutes),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 24),

                  // Duration
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.denim,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Duration',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          FlightTime.formatMinutes(_duration),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _handleCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.borderVisible),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTypography.button.copyWith(
                          color: AppColors.whiteDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.denim,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Confirm',
                        style: AppTypography.button,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom two-thumb slider for time range selection
/// Uses local state for smooth dragging, only notifies parent on snapped value changes
class _TimeRangeSlider extends StatefulWidget {
  final int totalMinutes;
  final int startMinutes;
  final int endMinutes;
  final double thumbSize;
  final double trackHeight;
  final int stepSize;
  final void Function(int) onStartChanged;
  final void Function(int) onEndChanged;

  const _TimeRangeSlider({
    required this.totalMinutes,
    required this.startMinutes,
    required this.endMinutes,
    required this.thumbSize,
    required this.trackHeight,
    required this.stepSize,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  @override
  State<_TimeRangeSlider> createState() => _TimeRangeSliderState();
}

class _TimeRangeSliderState extends State<_TimeRangeSlider> {
  // Local drag state for smooth visual feedback
  double? _dragStartPosition;
  double? _dragEndPosition;
  int _lastReportedStart = 0;
  int _lastReportedEnd = 0;

  @override
  void initState() {
    super.initState();
    _lastReportedStart = widget.startMinutes;
    _lastReportedEnd = widget.endMinutes;
  }

  @override
  void didUpdateWidget(_TimeRangeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync with parent state when not dragging
    if (_dragStartPosition == null) {
      _lastReportedStart = widget.startMinutes;
    }
    if (_dragEndPosition == null) {
      _lastReportedEnd = widget.endMinutes;
    }
  }

  int _snapToStep(int minutes) {
    return ((minutes / widget.stepSize).round() * widget.stepSize)
        .clamp(0, widget.totalMinutes);
  }

  double _minutesToPosition(int minutes, double trackWidth) {
    if (widget.totalMinutes <= 0) return 0;
    return (minutes / widget.totalMinutes) * trackWidth;
  }

  int _positionToMinutes(double position, double trackWidth) {
    if (trackWidth <= 0) return 0;
    final fraction = (position / trackWidth).clamp(0.0, 1.0);
    return (fraction * widget.totalMinutes).round();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Account for full thumb size on each side to prevent overflow
        final trackWidth = constraints.maxWidth - widget.thumbSize * 2;

        // Use local drag position if dragging, otherwise use widget values
        final startPosition = _dragStartPosition ??
            _minutesToPosition(widget.startMinutes, trackWidth);
        final endPosition = _dragEndPosition ??
            _minutesToPosition(widget.endMinutes, trackWidth);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final tapX = details.localPosition.dx - widget.thumbSize / 2;
            final minutes = _positionToMinutes(tapX, trackWidth);
            final snapped = _snapToStep(minutes);

            // Move nearest thumb
            final distToStart = (snapped - widget.startMinutes).abs();
            final distToEnd = (snapped - widget.endMinutes).abs();

            HapticFeedback.lightImpact();
            if (distToStart <= distToEnd && snapped < widget.endMinutes) {
              widget.onStartChanged(snapped);
            } else if (snapped > widget.startMinutes) {
              widget.onEndChanged(snapped);
            }
          },
          child: Container(
            height: widget.thumbSize + 24,
            padding: EdgeInsets.symmetric(horizontal: widget.thumbSize),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Background track
                Container(
                  height: widget.trackHeight,
                  decoration: BoxDecoration(
                    color: AppColors.nightRiderLight,
                    borderRadius: BorderRadius.circular(widget.trackHeight / 2),
                  ),
                ),

                // Selected range highlight
                Positioned(
                  left: startPosition,
                  width: (endPosition - startPosition).clamp(0, trackWidth) + widget.thumbSize,
                  child: Container(
                    height: widget.trackHeight,
                    decoration: BoxDecoration(
                      color: AppColors.denim,
                      borderRadius: BorderRadius.circular(widget.trackHeight / 2),
                    ),
                  ),
                ),

                // Start thumb
                Positioned(
                  left: startPosition,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: (_) {
                      setState(() {
                        _dragStartPosition = startPosition;
                      });
                    },
                    onHorizontalDragUpdate: (details) {
                      final newPosition = (_dragStartPosition! + details.delta.dx)
                          .clamp(0.0, endPosition - widget.stepSize / widget.totalMinutes * trackWidth);

                      setState(() {
                        _dragStartPosition = newPosition;
                      });

                      // Check if snapped value changed
                      final minutes = _positionToMinutes(newPosition, trackWidth);
                      final snapped = _snapToStep(minutes);
                      if (snapped != _lastReportedStart && snapped < widget.endMinutes) {
                        _lastReportedStart = snapped;
                        widget.onStartChanged(snapped);
                      }
                    },
                    onHorizontalDragEnd: (_) {
                      setState(() {
                        _dragStartPosition = null;
                      });
                    },
                    child: _Thumb(size: widget.thumbSize),
                  ),
                ),

                // End thumb
                Positioned(
                  left: endPosition,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: (_) {
                      setState(() {
                        _dragEndPosition = endPosition;
                      });
                    },
                    onHorizontalDragUpdate: (details) {
                      final minPosition = startPosition + widget.stepSize / widget.totalMinutes * trackWidth;
                      final newPosition = (_dragEndPosition! + details.delta.dx)
                          .clamp(minPosition, trackWidth);

                      setState(() {
                        _dragEndPosition = newPosition;
                      });

                      // Check if snapped value changed
                      final minutes = _positionToMinutes(newPosition, trackWidth);
                      final snapped = _snapToStep(minutes);
                      if (snapped != _lastReportedEnd && snapped > widget.startMinutes) {
                        _lastReportedEnd = snapped;
                        widget.onEndChanged(snapped);
                      }
                    },
                    onHorizontalDragEnd: (_) {
                      setState(() {
                        _dragEndPosition = null;
                      });
                    },
                    child: _Thumb(size: widget.thumbSize),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Thumb widget for the slider
class _Thumb extends StatelessWidget {
  final double size;

  const _Thumb({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.denim,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
