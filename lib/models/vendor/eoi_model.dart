class EoiModel {
  final String uuid;
  final String eoiNumber;
  final String title;
  final String vendorCategory;
  final String description;
  final String eligibilityCriteria;
  final DateTime publishDate;
  final DateTime lastDateSubmission;
  final String status;

  EoiModel({
    required this.uuid,
    required this.eoiNumber,
    required this.title,
    required this.vendorCategory,
    required this.description,
    required this.eligibilityCriteria,
    required this.publishDate,
    required this.lastDateSubmission,
    required this.status,
  });

  factory EoiModel.fromJson(Map<String, dynamic> json) {
    return EoiModel(
      uuid: json['uuid'] ?? '',
      eoiNumber: json['eoiNumber'] ?? '',
      title: json['title'] ?? '',
      vendorCategory: json['vendorCategory'] ?? '',
      description: json['description'] ?? '',
      eligibilityCriteria: json['eligibilityCriteria'] ?? '',
      publishDate: DateTime.parse(json['publishDate'] ?? DateTime.now().toIso8601String()),
      lastDateSubmission: DateTime.parse(json['lastDateSubmission'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? '',
    );
  }
}
