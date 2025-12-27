import 'dart:math';
import 'package:corp_pulse/models/data_models.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  final List<String> regionNames = [
    'Dharwad',
    'Kalaburagi',
    'Tumkur',
    'Andhra Pradesh',
    'Telangana',
  ];

  List<RegionReportRow> _cachedData = [];
  bool _isDataGenerated = false;

  Future<void> generateData() async {
    if (_isDataGenerated) return;

    final random = Random();
    List<RegionReportRow> rows = [];

    // Generate rows for each region
    for (var name in regionNames) {
      rows.add(_generateRandomRow(name, random));
    }

    // Sort by some criteria for Ranking (e.g., collectionPercent)
    rows.sort((a, b) => b.collectionPercent.compareTo(a.collectionPercent));

    // Assign Rank and Performance
    rows = rows.asMap().entries.map((entry) {
      final index = entry.key;
      final row = entry.value;

      // Re-create row with rank
      return RegionReportRow(
        regionName: row.regionName,
        regularDemand: row.regularDemand,
        regularCollection: row.regularCollection,
        ftod: row.ftod,
        collectionPercent: row.collectionPercent,
        b1_30Demand: row.b1_30Demand,
        b1_30Collection: row.b1_30Collection,
        b1_30Balance: row.b1_30Balance,
        b1_30ClosurePercent: row.b1_30ClosurePercent,
        b31_60Demand: row.b31_60Demand,
        b31_60Collection: row.b31_60Collection,
        b31_60Balance: row.b31_60Balance,
        b31_60ClosurePercent: row.b31_60ClosurePercent,
        pnpaDemand: row.pnpaDemand,
        pnpaCollection: row.pnpaCollection,
        pnpaBalance: row.pnpaBalance,
        pnpaClosurePercent: row.pnpaClosurePercent,
        totalNpaCases: row.totalNpaCases,
        activationAccount: row.activationAccount,
        activationAmount: row.activationAmount,
        closureAccount: row.closureAccount,
        closureAmount: row.closureAmount,
        rank: index + 1,
        performance: row.collectionPercent > 80 ? "Above Average" : "Below Average",
      );
    }).toList();

    // Compute Grand Total
    final totalRow = _computeGrandTotal(rows);

    // Combine: Regions + Grand Total
    _cachedData = [...rows, totalRow];
    _isDataGenerated = true;
  }

  RegionReportRow _generateRandomRow(String name, Random r) {
    // Helpers
    int randInt(int min, int max) => min + r.nextInt(max - min);

    // Regular
    int rDem = randInt(5000000, 20000000);
    int rCol = (rDem * (0.7 + r.nextDouble() * 0.29)).toInt(); // 70-99%
    double rColPct = (rCol / rDem) * 100;

    // 1-30
    int b1Dem = randInt(1000000, 5000000);
    int b1Col = (b1Dem * (0.5 + r.nextDouble() * 0.4)).toInt(); // 50-90%
    int b1Bal = b1Dem - b1Col;
    double b1Pct = (b1Col / b1Dem) * 100;

    // 31-60
    int b31Dem = randInt(500000, 2000000);
    int b31Col = (b31Dem * (0.4 + r.nextDouble() * 0.4)).toInt();
    int b31Bal = b31Dem - b31Col;
    double b31Pct = (b31Col / b31Dem) * 100;

    // PNPA
    int pDem = randInt(200000, 1000000);
    int pCol = (pDem * (0.3 + r.nextDouble() * 0.4)).toInt();
    int pBal = pDem - pCol;
    double pPct = (pCol / pDem) * 100;

    // NPA
    int npaCases = randInt(50, 500);
    int actAmt = randInt(1000000, 5000000);
    int clsAmt = (actAmt * (0.2 + r.nextDouble() * 0.4)).toInt();

    return RegionReportRow(
      regionName: name,
      regularDemand: rDem,
      regularCollection: rCol,
      ftod: randInt(100, 1000),
      collectionPercent: rColPct,
      b1_30Demand: b1Dem,
      b1_30Collection: b1Col,
      b1_30Balance: b1Bal,
      b1_30ClosurePercent: b1Pct,
      b31_60Demand: b31Dem,
      b31_60Collection: b31Col,
      b31_60Balance: b31Bal,
      b31_60ClosurePercent: b31Pct,
      pnpaDemand: pDem,
      pnpaCollection: pCol,
      pnpaBalance: pBal,
      pnpaClosurePercent: pPct,
      totalNpaCases: npaCases,
      activationAccount: randInt(10, 50),
      activationAmount: actAmt,
      closureAccount: randInt(5, 20),
      closureAmount: clsAmt,
      rank: 0, // Assigned later
      performance: '', // Assigned later
    );
  }

  RegionReportRow _computeGrandTotal(List<RegionReportRow> rows) {
    int sum(int Function(RegionReportRow) selector) => rows.fold(0, (p, c) => p + selector(c));

    int tRDem = sum((r) => r.regularDemand);
    int tRCol = sum((r) => r.regularCollection);

    int tB1Dem = sum((r) => r.b1_30Demand);
    int tB1Col = sum((r) => r.b1_30Collection);

    int tB31Dem = sum((r) => r.b31_60Demand);
    int tB31Col = sum((r) => r.b31_60Collection);

    int tPDem = sum((r) => r.pnpaDemand);
    int tPCol = sum((r) => r.pnpaCollection);

    return RegionReportRow(
      regionName: 'Grand Total',
      regularDemand: tRDem,
      regularCollection: tRCol,
      ftod: sum((r) => r.ftod),
      collectionPercent: tRDem == 0 ? 0 : (tRCol / tRDem) * 100,
      b1_30Demand: tB1Dem,
      b1_30Collection: tB1Col,
      b1_30Balance: sum((r) => r.b1_30Balance),
      b1_30ClosurePercent: tB1Dem == 0 ? 0 : (tB1Col / tB1Dem) * 100,
      b31_60Demand: tB31Dem,
      b31_60Collection: tB31Col,
      b31_60Balance: sum((r) => r.b31_60Balance),
      b31_60ClosurePercent: tB31Dem == 0 ? 0 : (tB31Col / tB31Dem) * 100,
      pnpaDemand: tPDem,
      pnpaCollection: tPCol,
      pnpaBalance: sum((r) => r.pnpaBalance),
      pnpaClosurePercent: tPDem == 0 ? 0 : (tPCol / tPDem) * 100,
      totalNpaCases: sum((r) => r.totalNpaCases),
      activationAccount: sum((r) => r.activationAccount),
      activationAmount: sum((r) => r.activationAmount),
      closureAccount: sum((r) => r.closureAccount),
      closureAmount: sum((r) => r.closureAmount),
      rank: 0,
      performance: '',
    );
  }

  List<RegionReportRow> getForRole(Role role, String? regionName) {
    if (role == Role.ceo) {
      return _cachedData;
    } else {
      // For Regional Manager and Branch User, show their region + Grand Total
      // Or just their region as per requirements?
      // Req: "Regional Manager -> sees only their region + grand total summary"
      // Req: "Branch/Team User -> simplified view (only 3–4 key KPI cards + their region)"

      // Let's filter: find the specific region row AND the Grand Total row
      return _cachedData.where((r) =>
        r.regionName == regionName || r.regionName == 'Grand Total'
      ).toList();
    }
  }
}
