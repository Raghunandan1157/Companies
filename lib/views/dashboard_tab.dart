import 'package:flutter/material.dart';
import 'package:corp_pulse/models/data_models.dart';
import 'package:corp_pulse/services/mock_data_service.dart';
import 'package:corp_pulse/components/neon_card.dart';
import 'package:corp_pulse/components/ring_gauge.dart';
import 'package:corp_pulse/theme/app_theme.dart';

class DashboardTab extends StatelessWidget {
  final UserSession session;

  const DashboardTab({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    // Get Data
    final rows = MockDataService().getForRole(session.role, session.assignedRegion);

    // For Dashboard, if CEO/RegionalManager, we want the Grand Total or specific region summary
    // If Branch user, they only see their region data anyway.
    // Let's pick the most relevant row to show KPIs for.
    // If CEO -> Show Grand Total summary + Top Region List (later)
    // If RM -> Show their region
    // If Branch -> Show their region

    // Find the primary row to display KPIs for
    RegionReportRow primaryRow;
    if (session.role == Role.ceo) {
      primaryRow = rows.firstWhere((r) => r.regionName == 'Grand Total', orElse: () => rows.first);
    } else {
      // For RM/Branch, the list includes Grand Total and their region.
      // We want their region (not grand total) for the main dashboard view usually?
      // Or maybe RM wants to see their region.
      primaryRow = rows.firstWhere((r) => r.regionName != 'Grand Total', orElse: () => rows.first);
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              '${session.role == Role.ceo ? "Global" : primaryRow.regionName} Dashboard',
              style: const TextStyle(
                shadows: [Shadow(color: Colors.black, blurRadius: 10)],
              ),
            ),
            background: _buildHeaderBackground(),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Performance Section
              Center(
                child: NeonCard(
                  glowColor: primaryRow.performance == "Above Average" ? AppTheme.neonGreen : AppTheme.neonRed,
                  child: Column(
                    children: [
                      const Text("OVERALL PERFORMANCE", style: TextStyle(color: Colors.white70, letterSpacing: 1.5)),
                      const SizedBox(height: 20),
                      RingGauge(
                        percentage: primaryRow.collectionPercent,
                        label: primaryRow.performance.toUpperCase(),
                        color: primaryRow.performance == "Above Average" ? AppTheme.neonGreen : AppTheme.neonRed,
                        size: 200,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // KPI Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                  if (session.role == Role.branchUser) crossAxisCount = 1;

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: _buildKPICards(primaryRow, session.role),
                  );
                },
              ),

              const SizedBox(height: 20),

              // CEO Exclusive: Top Regions
              if (session.role == Role.ceo) ...[
                 const Padding(
                   padding: EdgeInsets.symmetric(vertical: 16.0),
                   child: Text("Top Performing Regions", style: TextStyle(color: Colors.white, fontSize: 18)),
                 ),
                 ...rows
                    .where((r) => r.regionName != 'Grand Total')
                    .take(3) // Top 3 because they are sorted in service
                    .map((r) => _buildRegionListItem(context, r)),
                 const SizedBox(height: 80), // Space for fab/bottom nav
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.neonPurple.withOpacity(0.3),
            AppTheme.background,
          ],
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.1,
          child: Icon(Icons.show_chart, size: 200, color: Colors.white),
        ),
      ),
    );
  }

  List<Widget> _buildKPICards(RegionReportRow row, Role role) {
    List<Widget> cards = [];

    // Common Cards
    cards.add(_kpiCard("Reg Collection", "${row.collectionPercent.toStringAsFixed(1)}%",
      row.collectionPercent > 80 ? AppTheme.neonGreen : AppTheme.neonAmber));

    cards.add(_kpiCard("Reg Demand", AppTheme.formatCompact(row.regularDemand), AppTheme.neonCyan));

    if (role != Role.branchUser) {
        cards.add(_kpiCard("1-30 Closure", "${row.b1_30ClosurePercent.toStringAsFixed(1)}%",
          row.b1_30ClosurePercent > 50 ? AppTheme.neonGreen : AppTheme.neonRed));

        cards.add(_kpiCard("PNPA Closure", "${row.pnpaClosurePercent.toStringAsFixed(1)}%",
           row.pnpaClosurePercent > 30 ? AppTheme.neonGreen : AppTheme.neonRed));

        cards.add(_kpiCard("Total NPA Cases", row.totalNpaCases.toString(),
           row.totalNpaCases < 100 ? AppTheme.neonGreen : AppTheme.neonRed));

        cards.add(_kpiCard("Activation Amt", AppTheme.formatCompact(row.activationAmount), AppTheme.neonPurple));
    } else {
        // Branch user simplified
        cards.add(_kpiCard("FTOD", row.ftod.toString(), Colors.white));
        cards.add(_kpiCard("Rank", "#${row.rank}", AppTheme.neonAmber));
    }

    return cards;
  }

  Widget _kpiCard(String title, String value, Color glow) {
    return NeonCard(
      glowColor: glow,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.white60, fontSize: 12), textAlign: TextAlign.center,),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, shadows: [Shadow(color: glow, blurRadius: 10)])),
        ],
      ),
    );
  }

  Widget _buildRegionListItem(BuildContext context, RegionReportRow row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: NeonCard(
        glowColor: Colors.white,
        intensity: 0.5,
        child: ListTile(
          leading: CircleAvatar(backgroundColor: Colors.white10, child: Text("#${row.rank}", style: const TextStyle(color: Colors.white))),
          title: Text(row.regionName, style: const TextStyle(color: Colors.white)),
          trailing: Text("${row.collectionPercent.toStringAsFixed(1)}%", style: TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold)),
          onTap: () {
            // Navigate to detail
            Navigator.pushNamed(context, '/region_detail', arguments: row);
          },
        ),
      ),
    );
  }
}
