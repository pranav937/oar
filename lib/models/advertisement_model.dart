class Advertisement {
  final String uuid;
  final String postName;
  final String organization; // From requisition/department
  final String payScale;
  final String qualifications;
  final String lastDateToApply;
  final String status;

  Advertisement({
    required this.uuid,
    required this.postName,
    required this.organization,
    required this.payScale,
    required this.qualifications,
    required this.lastDateToApply,
    required this.status,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      uuid: json['uuid'] ?? '',
      postName: json['postName'] ?? json['requisition']?['postName'] ?? 'Position',
      organization: json['departmentName'] ?? json['requisition']?['department']?['name'] ?? 'Organization',
      payScale: json['payScale'] ?? json['requisition']?['payScale'] ?? 'N/A',
      qualifications: json['qualifications'] ?? json['requisition']?['qualifications'] ?? '',
      lastDateToApply: json['lastDateToApply'] ?? '',
      status: json['status'] ?? 'Active',
    );
  }
}
