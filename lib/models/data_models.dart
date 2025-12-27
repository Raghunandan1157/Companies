enum Role {
  ceo,
  regionalManager,
  branchUser,
}

class RegionReportRow {
  final String regionName;

  // Regular
  final int regularDemand;
  final int regularCollection;
  final int ftod;
  final double collectionPercent;

  // 1–30 Bucket
  final int b1_30Demand;
  final int b1_30Collection;
  final int b1_30Balance;
  final double b1_30ClosurePercent;

  // 31–60 Bucket
  final int b31_60Demand;
  final int b31_60Collection;
  final int b31_60Balance;
  final double b31_60ClosurePercent;

  // PNPA
  final int pnpaDemand;
  final int pnpaCollection;
  final int pnpaBalance;
  final double pnpaClosurePercent;

  // NPA
  final int totalNpaCases;
  final int activationAccount;
  final int activationAmount;
  final int closureAccount;
  final int closureAmount;

  // Rank + Performance
  final int rank;
  final String performance; // "Above Average", "Below Average"

  const RegionReportRow({
    required this.regionName,
    required this.regularDemand,
    required this.regularCollection,
    required this.ftod,
    required this.collectionPercent,
    required this.b1_30Demand,
    required this.b1_30Collection,
    required this.b1_30Balance,
    required this.b1_30ClosurePercent,
    required this.b31_60Demand,
    required this.b31_60Collection,
    required this.b31_60Balance,
    required this.b31_60ClosurePercent,
    required this.pnpaDemand,
    required this.pnpaCollection,
    required this.pnpaBalance,
    required this.pnpaClosurePercent,
    required this.totalNpaCases,
    required this.activationAccount,
    required this.activationAmount,
    required this.closureAccount,
    required this.closureAmount,
    required this.rank,
    required this.performance,
  });

  // Helper to create an empty/zero row for initialization
  factory RegionReportRow.empty() {
    return const RegionReportRow(
      regionName: '',
      regularDemand: 0,
      regularCollection: 0,
      ftod: 0,
      collectionPercent: 0.0,
      b1_30Demand: 0,
      b1_30Collection: 0,
      b1_30Balance: 0,
      b1_30ClosurePercent: 0.0,
      b31_60Demand: 0,
      b31_60Collection: 0,
      b31_60Balance: 0,
      b31_60ClosurePercent: 0.0,
      pnpaDemand: 0,
      pnpaCollection: 0,
      pnpaBalance: 0,
      pnpaClosurePercent: 0.0,
      totalNpaCases: 0,
      activationAccount: 0,
      activationAmount: 0,
      closureAccount: 0,
      closureAmount: 0,
      rank: 0,
      performance: '',
    );
  }
}

class UserSession {
  final String name;
  final String employeeId;
  final Role role;
  final String? assignedRegion; // Null if CEO, otherwise set

  UserSession({
    required this.name,
    required this.employeeId,
    required this.role,
    this.assignedRegion,
  });
}
