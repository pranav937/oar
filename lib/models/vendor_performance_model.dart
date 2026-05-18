class VendorPerformanceModel {
  final double executionEfficiency;
  final double deliveryTimeliness;
  final int policyCompliance;
  final List<KpiLogItem> evaluationLog;

  VendorPerformanceModel({
    required this.executionEfficiency,
    required this.deliveryTimeliness,
    required this.policyCompliance,
    required this.evaluationLog,
  });

  factory VendorPerformanceModel.fromJson(Map<String, dynamic> json) {
    // Handling case where data might be a list or empty
    // If it's a summary object, parse accordingly. 
    // For now, providing defaults based on the design screenshot.
    return VendorPerformanceModel(
      executionEfficiency: (json['executionEfficiency'] ?? 96.4).toDouble(),
      deliveryTimeliness: (json['deliveryTimeliness'] ?? 92.0).toDouble(),
      policyCompliance: json['policyCompliance'] ?? 100,
      evaluationLog: (json['evaluationLog'] as List? ?? [])
          .map((item) => KpiLogItem.fromJson(item))
          .toList(),
    );
  }
}

class KpiLogItem {
  final String metric;
  final String score;
  final String date;
  final String status;

  KpiLogItem({
    required this.metric,
    required this.score,
    required this.date,
    required this.status,
  });

  factory KpiLogItem.fromJson(Map<String, dynamic> json) {
    return KpiLogItem(
      metric: json['metric'] ?? 'General Efficiency',
      score: json['score'] ?? 'N/A',
      date: json['date'] ?? '',
      status: json['status'] ?? 'VALIDATED',
    );
  }
}
