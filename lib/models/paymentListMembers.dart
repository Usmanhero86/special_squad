class Payments {
  final String id;
  final String memberId;
  final String memberName;
  final double amount;
  final DateTime paymentDate;
  final String status;
  final String method;
  final String reference;

  Payments({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.paymentDate,
    required this.status,
    required this.method,
    required this.reference,
  });

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';

  factory Payments.fromJson(Map<String, dynamic> json) {
    return Payments(
      id: json['id'],
      memberId: json['memberId'],
      memberName: json['member']['fullName'],
      amount: double.parse(json['amount']),
      paymentDate: DateTime.parse(json['paymentDate']),
      status: json['paymentStatus'],
      method: json['paymentMethod'],
      reference: json['referenceNumber'],
    );
  }
}