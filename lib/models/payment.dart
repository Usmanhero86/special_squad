class Payment {
  String id;
  String memberId;
  double amount;
  DateTime paymentDate;
  String paymentMethod;
  String purpose;
  String? receiptNumber;
  String? bankReference;
  String status;
  String? notes;
  String? attachmentUrl;
  String? memberName; // Added for API response
  String? description; // Added for API response

  Payment({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.purpose,
    this.receiptNumber,
    this.bankReference,
    this.status = 'Completed',
    this.notes,
    this.attachmentUrl,
    this.memberName,
    this.description,
  });

  // Factory method for API response
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      memberId: json['memberId'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : DateTime.now(),
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      purpose: json['description'] ?? 'Payment',
      receiptNumber: json['referenceNumber'],
      bankReference: json['referenceNumber'],
      status: json['paymentStatus'] ?? 'PENDING',
      notes: json['description'],
      memberName: json['member']?['fullName'],
      description: json['description'],
    );
  }

  // Add these factory methods
  factory Payment.fromMap(Map<String, dynamic> data, String id) {
    return Payment(
      id: id,
      memberId: data['memberId'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      paymentDate: DateTime.fromMillisecondsSinceEpoch(data['paymentDate']),
      paymentMethod: data['paymentMethod'] ?? 'Cash',
      purpose: data['purpose'] ?? 'Membership Fee',
      receiptNumber: data['receiptNumber'],
      bankReference: data['bankReference'],
      status: data['status'] ?? 'Pending',
      notes: data['notes'],
      attachmentUrl: data['attachmentUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'amount': amount,
      'paymentDate': paymentDate.millisecondsSinceEpoch,
      'paymentMethod': paymentMethod,
      'purpose': purpose,
      'receiptNumber': receiptNumber,
      'bankReference': bankReference,
      'status': status,
      'notes': notes,
      'attachmentUrl': attachmentUrl,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // Optional: Add a copyWith method for updates
  Payment copyWith({
    String? id,
    String? memberId,
    double? amount,
    DateTime? paymentDate,
    String? paymentMethod,
    String? purpose,
    String? receiptNumber,
    String? bankReference,
    String? status,
    String? notes,
    String? attachmentUrl,
  }) {
    return Payment(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      purpose: purpose ?? this.purpose,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      bankReference: bankReference ?? this.bankReference,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }
}
