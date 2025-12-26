import 'package:flutter/material.dart';
import 'package:corp_pulse/models/data_models.dart';
import 'package:corp_pulse/components/neon_card.dart';
import 'package:corp_pulse/components/mini_bar_chart.dart';
import 'package:corp_pulse/theme/app_theme.dart';
import 'package:corp_pulse/components/glass_background.dart';

class RegionDetailScreen extends StatelessWidget {
  final RegionReportRow row;

  const RegionDetailScreen({super.key, required this.row});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(row.regionName, style: TextStyle(color: Colors.white, shadows: [Shadow(color: AppTheme.neonCyan, blurRadius: 10)])),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.neonCyan.withOpacity(0.2), Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter
                  )
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader("Regular Performance"),
                NeonCard(
                  glowColor: AppTheme.neonCyan,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           _statItem("Demand", AppTheme.formatNumber(row.regularDemand)),
                           _statItem("Collection", AppTheme.formatNumber(row.regularCollection)),
                           _statItem("FTOD", AppTheme.formatNumber(row.ftod)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      MiniBarChart(
                        values: [row.regularDemand.toDouble(), row.regularCollection.toDouble()],
                        labels: const ["Demand", "Collect"],
                        barColor: AppTheme.neonCyan,
                        height: 150,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                _buildSectionHeader("Bucket 1-30"),
                NeonCard(
                  glowColor: AppTheme.neonPurple,
                  child: Column(
                    children: [
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           _statItem("Demand", AppTheme.formatNumber(row.b1_30Demand)),
                           _statItem("Collect", AppTheme.formatNumber(row.b1_30Collection)),
                           _statItem("Percent", "${row.b1_30ClosurePercent.toStringAsFixed(1)}%"),
                        ],
                      ),
                      const SizedBox(height: 20),
                      MiniBarChart(
                        values: [row.b1_30Demand.toDouble(), row.b1_30Collection.toDouble(), row.b1_30Balance.toDouble()],
                        labels: const ["Dem", "Col", "Bal"],
                        barColor: AppTheme.neonPurple,
                        height: 150,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                _buildSectionHeader("NPA Status"),
                NeonCard(
                  glowColor: AppTheme.neonRed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                       _statItem("Cases", "${row.totalNpaCases}"),
                       _statItem("Act Amt", AppTheme.formatCompact(row.activationAmount)),
                       _statItem("Cls Amt", AppTheme.formatCompact(row.closureAmount)),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8),
      child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.white54, letterSpacing: 1.2)),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
