import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mindsport/models/mood_model.dart';
import 'package:intl/intl.dart';
import 'package:mindsport/main.dart'; // For theme colors

class PerformanceChart extends StatefulWidget {
  final List<MoodEntry> history;

  const PerformanceChart({super.key, required this.history});

  @override
  State<PerformanceChart> createState() => _PerformanceChartState();
}

class _PerformanceChartState extends State<PerformanceChart> {
  // Default to 7 days
  int _dataLimit = 7;

  @override
  Widget build(BuildContext context) {
    // 1. Prepare Data: Sort Oldest -> Newest
    final sortedData = List<MoodEntry>.from(widget.history)
      ..sort((a, b) => a.date.compareTo(b.date));

    // 2. Slice Data based on selection
    final data = sortedData.length > _dataLimit
        ? sortedData.sublist(sortedData.length - _dataLimit)
        : sortedData;

    if (data.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: Text(
            "Log your stats to see the graph!",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: [
        // --- 1. TIME PERIOD TOGGLE ---
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _TimeChip(
              label: "Last 7",
              isSelected: _dataLimit == 7,
              onTap: () => setState(() => _dataLimit = 7),
            ),
            const SizedBox(width: 12),
            _TimeChip(
              label: "Last 30",
              isSelected: _dataLimit == 30,
              onTap: () => setState(() => _dataLimit = 30),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // --- 2. LEGEND ---
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: MindSportTheme.primaryGreen, label: "Sleep"),
            const SizedBox(width: 20),
            _LegendItem(color: Colors.orangeAccent, label: "Strain"),
          ],
        ),
        const SizedBox(height: 20),

        // --- 3. CHART ---
        AspectRatio(
          aspectRatio: 1.70,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 2, // Lines every 2 units
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.1),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    // Dynamic Interval: Show every day for 7 days, every 5 days for 30
                    interval: _dataLimit == 7 ? 1 : 5,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < data.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            // Format: "Mon" (7 days) or "Oct 12" (30 days)
                            _dataLimit == 7
                                ? DateFormat('E').format(data[index].date)[0]
                                : DateFormat('d/M').format(data[index].date),
                            style: const TextStyle(
                              color: Color(0xff68737d),
                              fontWeight: FontWeight.bold,
                              fontSize: 10, // Smaller font for dates
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 2,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Color(0xff67727d),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      );
                    },
                    reservedSize: 25,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (data.length - 1).toDouble(),
              minY: 0,
              maxY: 10,
              lineBarsData: [
                // Line 1: Sleep (Green)
                LineChartBarData(
                  spots: data.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.sleep.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: MindSportTheme.primaryGreen,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: _dataLimit == 7), // Hide dots on 30-day view
                  belowBarData: BarAreaData(
                    show: true,
                    color: MindSportTheme.primaryGreen.withOpacity(0.1),
                  ),
                ),
                // Line 2: Physical (Orange)
                LineChartBarData(
                  spots: data.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.physical.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: Colors.orangeAccent,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: _dataLimit == 7),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- HELPER WIDGETS ---

class _TimeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? MindSportTheme.primaryGreen : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      ],
    );
  }
}