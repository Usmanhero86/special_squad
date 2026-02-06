class PaymentResponse {
  final bool responseSuccessful;
  final String responseMessage;
  final PaymentBody responseBody;

  PaymentResponse({
    required this.responseSuccessful,
    required this.responseMessage,
    required this.responseBody,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      responseSuccessful: json['responseSuccessful'],
      responseMessage: json['responseMessage'],
      responseBody: PaymentBody.fromJson(json['responseBody']),
    );
  }
}

class PaymentBody {
  final List<Payment> data;
  final int total;
  final int page;
  final int limit;

  PaymentBody({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PaymentBody.fromJson(Map<String, dynamic> json) {
    return PaymentBody(
      data: (json['data'] as List)
          .map((e) => Payment.fromJson(e))
          .toList(),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
    );
  }
}

class Payment {
  final String id;
  final String memberId;
  final String amount;
  final DateTime paymentDate;
  final String paymentStatus;
  final String paymentMethod;
  final String referenceNumber;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Member member;
  final RecordedBy recordedBy;

  Payment({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.paymentDate,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.referenceNumber,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.member,
    required this.recordedBy,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      memberId: json['memberId'],
      amount: json['amount'],
      paymentDate: DateTime.parse(json['paymentDate']),
      paymentStatus: json['paymentStatus'],
      paymentMethod: json['paymentMethod'],
      referenceNumber: json['referenceNumber'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      member: Member.fromJson(json['member']),
      recordedBy: RecordedBy.fromJson(json['recordedBy']),
    );
  }
}

class Member {
  final String id;
  final String fullName;

  Member({
    required this.id,
    required this.fullName,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      fullName: json['fullName'],
    );
  }
}

class RecordedBy {
  final String id;
  final String email;
  final String name;
  final String role;
  final String status;

  RecordedBy({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
  });

  factory RecordedBy.fromJson(Map<String, dynamic> json) {
    return RecordedBy(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      status: json['status'],
    );
  }
}