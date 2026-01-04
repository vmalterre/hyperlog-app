import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'glass_card.dart';

/// Data point for the trust evolution chart
class TrustChartData {
  final DateTime month;
  final int cumulativeLogged;
  final int cumulativeTracked;
  final int cumulativeEndorsed;

  const TrustChartData({
    required this.month,
    required this.cumulativeLogged,
    required this.cumulativeTracked,
    required this.cumulativeEndorsed,
  });

  int get total => cumulativeLogged + cumulativeTracked + cumulativeEndorsed;
}

/// A cumulative stacked area chart showing trust level evolution over time
class TrustEvolutionChart extends StatefulWidget {
  final List<TrustChartData> data;

  const TrustEvolutionChart({
    super.key,
    required this.data,
  });

  @override
  State<TrustEvolutionChart> createState() => _TrustEvolutionChartState();
}

class _TrustEvolutionChartState extends State<TrustEvolutionChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Trust Evolution', style: AppTypography.h4),
              _buildLegend(),
            ],
          ),
          const SizedBox(height: 24),
          // Chart
          SizedBox(
            height: 200,
            child: LineChart(
              _buildChartData(),
              duration: const Duration(milliseconds: 300),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trust Evolution', style: AppTypography.h4),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.show_chart,
                  size: 48,
                  color: AppColors.whiteDarker,
                ),
                const SizedBox(height: 16),
                Text(
                  'No flight data yet',
                  style: AppTypography.body.copyWith(
                    color: AppColors.whiteDarker,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _legendItem(AppColors.loggedBlue, 'Logged'),
        const SizedBox(width: 10),
        _legendItem(AppColors.trackedAmber, 'Tracked'),
        const SizedBox(width: 10),
        _legendItem(AppColors.endorsedGreen, 'Endorsed'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  LineChartData _buildChartData() {
    final maxY = widget.data.isEmpty
        ? 10.0
        : (widget.data.map((d) => d.total).reduce((a, b) => a > b ? a : b) * 1.1)
            .ceilToDouble();

    return LineChartData(
      minY: 0,
      maxY: maxY < 5 ? 5 : maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppColors.white.withValues(alpha: 0.05),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= widget.data.length) {
                return const SizedBox.shrink();
              }
              // Show every other month if more than 6 data points
              if (widget.data.length > 6 && index % 2 != 0) {
                return const SizedBox.shrink();
              }
              final date = widget.data[index].month;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  DateFormat('MMM').format(date),
                  style: AppTypography.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.whiteDarker,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: maxY / 4,
            getTitlesWidget: (value, meta) {
              if (value == 0) return const SizedBox.shrink();
              return Text(
                value.toInt().toString(),
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.whiteDarker,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spot) => AppColors.nightRiderDark,
          tooltipRoundedRadius: 8,
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final dataIndex = spot.x.toInt();
              if (dataIndex < 0 || dataIndex >= widget.data.length) {
                return null;
              }
              final data = widget.data[dataIndex];
              final color = _getColorForLineIndex(spot.barIndex);
              final label = _getLabelForLineIndex(spot.barIndex);
              final value = _getValueForLineIndex(spot.barIndex, data);
              return LineTooltipItem(
                '$label: $value',
                AppTypography.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList();
          },
        ),
        touchCallback: (event, response) {
          setState(() {
            if (event is FlTapUpEvent || event is FlPanEndEvent) {
              _touchedIndex = null;
            } else if (response?.lineBarSpots != null &&
                response!.lineBarSpots!.isNotEmpty) {
              _touchedIndex = response.lineBarSpots!.first.x.toInt();
            }
          });
        },
      ),
      lineBarsData: [
        // Endorsed (green) - bottom layer
        _buildLineBarData(
          spots: widget.data.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value.cumulativeEndorsed.toDouble());
          }).toList(),
          color: AppColors.endorsedGreen,
        ),
        // Tracked (amber) - middle layer (stacked on endorsed)
        _buildLineBarData(
          spots: widget.data.asMap().entries.map((e) {
            final stacked = e.value.cumulativeEndorsed + e.value.cumulativeTracked;
            return FlSpot(e.key.toDouble(), stacked.toDouble());
          }).toList(),
          color: AppColors.trackedAmber,
        ),
        // Logged (blue) - top layer (stacked on tracked + endorsed)
        _buildLineBarData(
          spots: widget.data.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value.total.toDouble());
          }).toList(),
          color: AppColors.loggedBlue,
        ),
      ],
    );
  }

  LineChartBarData _buildLineBarData({
    required List<FlSpot> spots,
    required Color color,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final isHighlighted = _touchedIndex == index;
          return FlDotCirclePainter(
            radius: isHighlighted ? 6 : 3,
            color: color,
            strokeWidth: isHighlighted ? 2 : 0,
            strokeColor: AppColors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.15),
      ),
    );
  }

  Color _getColorForLineIndex(int index) {
    switch (index) {
      case 0:
        return AppColors.endorsedGreen;
      case 1:
        return AppColors.trackedAmber;
      case 2:
        return AppColors.loggedBlue;
      default:
        return AppColors.white;
    }
  }

  String _getLabelForLineIndex(int index) {
    switch (index) {
      case 0:
        return 'Endorsed';
      case 1:
        return 'Tracked';
      case 2:
        return 'Logged';
      default:
        return '';
    }
  }

  int _getValueForLineIndex(int index, TrustChartData data) {
    switch (index) {
      case 0:
        return data.cumulativeEndorsed;
      case 1:
        return data.cumulativeTracked;
      case 2:
        return data.cumulativeLogged;
      default:
        return 0;
    }
  }
}
