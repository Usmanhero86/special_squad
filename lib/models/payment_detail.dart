class PaymentDetail {
  final String id;
  final String memberId;
  final String amount;
  final DateTime paymentDate;
  final String paymentStatus;
  final String paymentMethod;
  final String referenceNumber;
  final String description;
  final String recordedById;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentDetail({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.paymentDate,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.referenceNumber,
    required this.description,
    required this.recordedById,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    return PaymentDetail(
      id: json['id'] ?? '',
      memberId: json['memberId'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : DateTime.now(),
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      referenceNumber: json['referenceNumber'] ?? '',
      description: json['description'] ?? '',
      recordedById: json['recordedById'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'referenceNumber': referenceNumber,
      'description': description,
      'recordedById': recordedById,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  double get amountAsDouble => double.tryParse(amount) ?? 0.0;

  bool get isCompleted => paymentStatus.toUpperCase() == 'COMPLETED';
}
