class VendorInvoiceModel {
  final String uuid;
  final String invoiceNumber;
  final double baseAmount;
  final double taxAmount;
  final double totalAmount;
  final String status;
  final DateTime invoiceDate;
  final String? workOrderNumber;

  VendorInvoiceModel({
    required this.uuid,
    required this.invoiceNumber,
    required this.baseAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.status,
    required this.invoiceDate,
    this.workOrderNumber,
  });

  factory VendorInvoiceModel.fromJson(Map<String, dynamic> json) {
    return VendorInvoiceModel(
      uuid: json['uuid'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? 'INV-${json['id'] ?? '000'}',
      baseAmount: (json['baseAmount'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      invoiceDate: DateTime.parse(json['invoiceDate'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      workOrderNumber: json['workOrderNumber'],
    );
  }
}

class VendorPaymentModel {
  final String uuid;
  final double amount;
  final String paymentMethod;
  final String transactionId;
  final String status;
  final DateTime paymentDate;

  VendorPaymentModel({
    required this.uuid,
    required this.amount,
    required this.paymentMethod,
    required this.transactionId,
    required this.status,
    required this.paymentDate,
  });

  factory VendorPaymentModel.fromJson(Map<String, dynamic> json) {
    return VendorPaymentModel(
      uuid: json['uuid'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'BANK TRANSFER',
      transactionId: json['transactionId'] ?? 'TXN-${json['id'] ?? '000'}',
      status: json['status'] ?? 'COMPLETED',
      paymentDate: DateTime.parse(json['paymentDate'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
