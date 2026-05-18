class WorkOrderModel {
  final String uuid;
  final String woNumber;
  final String scopeOfWork;
  final DateTime startDate;
  final DateTime endDate;
  final double woValue;
  final String status;
  final String remarks;

  WorkOrderModel({
    required this.uuid,
    required this.woNumber,
    required this.scopeOfWork,
    required this.startDate,
    required this.endDate,
    required this.woValue,
    required this.status,
    required this.remarks,
  });

  factory WorkOrderModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderModel(
      uuid: json['uuid'] ?? '',
      woNumber: json['woNumber'] ?? '',
      scopeOfWork: json['scopeOfWork'] ?? '',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      woValue: (json['woValue'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      remarks: json['remarks'] ?? '',
    );
  }
}
