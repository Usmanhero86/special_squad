class PaymentMember {
  final String id;
  final String fullName;
  final String idNo;
  final String rifleNo;
  final String? locationId;
  final String? location; // ✅ ADD THIS
  final String? phoneNumber;
  final String? position;
  final String? photo;
  final String status;

  final String paymentStatus;
  final double amount;

  PaymentMember({
    required this.id,
    required this.fullName,
    required this.idNo,
    required this.rifleNo,
    this.locationId,
    this.location,
    this.phoneNumber,
    this.position,
    this.photo,
    required this.status,
    required this.paymentStatus,
    required this.amount,
  });

  factory PaymentMember.fromJson(Map<String, dynamic> json) {
    return PaymentMember(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? 'Unknown',
      idNo: json['idNo'] ?? '',
      rifleNo: json['rifleNo'] ?? '',
      locationId: json['locationId'],
      location: json['location'], // ✅ MAP IT
      phoneNumber: json['phoneNumber'],
      position: json['position'],
      photo: json['photo'],
      status: json['status'] ?? 'ACTIVE',
      paymentStatus:
      (json['paymentStatus'] ?? 'unpaid').toString().toUpperCase(),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
    );
  }

  bool get isPaid =>
      paymentStatus == 'PAID' || paymentStatus == 'COMPLETED';
}