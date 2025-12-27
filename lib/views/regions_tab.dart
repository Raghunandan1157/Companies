import 'package:flutter/material.dart';
import 'package:corp_pulse/models/data_models.dart';
import 'package:corp_pulse/services/mock_data_service.dart';
import 'package:corp_pulse/theme/app_theme.dart';
import 'package:corp_pulse/components/percent_badge.dart';

class RegionsTab extends StatelessWidget {
  final UserSession session;

  const RegionsTab({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final rows = MockDataService().getForRole(session.role, session.assignedRegion);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Regional Reports"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            headingRowColor: MaterialStateProperty.all(Colors.white10),
            dataRowColor: MaterialStateProperty.all(Colors.transparent),
            columns: const [
              DataColumn(label: Text('Region', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Reg Dem')),
              DataColumn(label: Text('Reg Col')),
              DataColumn(label: Text('Reg %')),
              DataColumn(label: Text('1-30 %')),
              DataColumn(label: Text('31-60 %')),
              DataColumn(label: Text('PNPA %')),
              DataColumn(label: Text('NPA Cases')),
              DataColumn(label: Text('Rank')),
            ],
            rows: rows.map((row) {
              return DataRow(
                onSelectChanged: (selected) {
                  if (selected == true) {
                     Navigator.pushNamed(context, '/region_detail', arguments: row);
                  }
                },
                cells: [
                  DataCell(Text(row.regionName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.neonCyan))),
                  DataCell(Text(AppTheme.formatNumber(row.regularDemand))),
                  DataCell(Text(AppTheme.formatNumber(row.regularCollection))),
                  DataCell(PercentBadge(value: row.collectionPercent)),
                  DataCell(PercentBadge(value: row.b1_30ClosurePercent)),
                  DataCell(PercentBadge(value: row.b31_60ClosurePercent)),
                  DataCell(PercentBadge(value: row.pnpaClosurePercent)),
                  DataCell(Text(row.totalNpaCases.toString(), style: TextStyle(color: row.totalNpaCases > 100 ? AppTheme.neonRed : AppTheme.neonGreen))),
                  DataCell(Text("#${row.rank}")),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
