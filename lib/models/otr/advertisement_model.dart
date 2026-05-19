class Advertisement {
  final String uuid;
  final String postName;
  final String organization; // From requisition/department
  final String payScale;
  final String qualifications;
  final String lastDateToApply;
  final String status;

  final int vacancies;
  final String advNumber;
  final String contentEnglish;
  final String contentHindi;
  final String postCode;
  final String examType;
  final String? experience;
  final String? relaxationRules;
  final int minAge;
  final int maxAge;
  final List<VacancyBreakdown> breakdowns;
  final List<ApplicationFee> fees;

  Advertisement({
    required this.uuid,
    required this.postName,
    required this.organization,
    required this.payScale,
    required this.qualifications,
    required this.lastDateToApply,
    required this.status,
    required this.vacancies,
    required this.advNumber,
    required this.contentEnglish,
    required this.contentHindi,
    required this.postCode,
    required this.examType,
    this.experience,
    this.relaxationRules,
    required this.minAge,
    required this.maxAge,
    required this.breakdowns,
    required this.fees,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    final req = json['requisition'] ?? {};
    final dept = req['department'] ?? {};
    final bList = req['vacancyBreakdowns'] as List? ?? [];
    
    return Advertisement(
      uuid: json['uuid'] ?? '',
      postName: req['postName'] ?? 'Position',
      organization: dept['name'] ?? 'Department: ${dept['code'] ?? 'N/A'}',
      payScale: req['payScale'] ?? 'N/A',
      qualifications: req['qualifications'] ?? 'N/A',
      lastDateToApply: json['lastDateToApply'] ?? 'N/A',
      status: json['response_status'] ?? json['status'] ?? 'Active',
      vacancies: req['totalVacancies'] ?? 0,
      advNumber: json['advNumber'] ?? 'N/A',
      contentEnglish: json['contentEnglish'] ?? '',
      contentHindi: json['contentHindi'] ?? '',
      postCode: req['postCode'] ?? '',
      examType: req['examType'] ?? '',
      experience: req['experience'],
      relaxationRules: req['relaxationRules'],
      minAge: req['minAge'] ?? 0,
      maxAge: req['maxAge'] ?? 0,
      breakdowns: bList.map((x) => VacancyBreakdown.fromJson(x)).toList(),
      fees: (req['fees'] as List? ?? []).map((x) => ApplicationFee.fromJson(x)).toList(),
    );
  }
}

class ApplicationFee {
  final String category;
  final int amount;
  final bool isExempted;

  ApplicationFee({
    required this.category,
    required this.amount,
    required this.isExempted,
  });

  factory ApplicationFee.fromJson(Map<String, dynamic> json) {
    return ApplicationFee(
      category: json['category'] ?? 'N/A',
      amount: json['amount'] ?? 0,
      isExempted: json['isExempted'] ?? false,
    );
  }
}

class VacancyBreakdown {
  final String category;
  final int allocatedPosts;
  final double percentage;
  final bool isHorizontal;

  VacancyBreakdown({
    required this.category,
    required this.allocatedPosts,
    required this.percentage,
    required this.isHorizontal,
  });

  factory VacancyBreakdown.fromJson(Map<String, dynamic> json) {
    return VacancyBreakdown(
      category: json['category'] ?? 'N/A',
      allocatedPosts: json['allocatedPosts'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      isHorizontal: json['isHorizontal'] ?? false,
    );
  }
}
