class MemberDetail {
  final String id;
  final String fullName;
  final String idNo;
  final String rifleNo;
  final String phoneNumber;
  final String location;
  final String position;
  final String status;
  final String? photo;
  final DateTime dateOfBirth;
  final DateTime createdAt;

  MemberDetail({
    required this.id,
    required this.fullName,
    required this.idNo,
    required this.rifleNo,
    required this.phoneNumber,
    required this.location,
    required this.position,
    required this.status,
    required this.photo,
    required this.dateOfBirth,
    required this.createdAt,
  });

  /// ✅ ADD IT RIGHT HERE
  bool get isActive => status.toUpperCase() == 'ACTIVE';

  factory MemberDetail.fromJson(Map<String, dynamic> json) {
    return MemberDetail(
      id: json['id'],
      fullName: json['fullName'],
      idNo: json['idNo'],
      rifleNo: json['rifleNo'],
      phoneNumber: json['phoneNumber'],
      location: json['location'],
      position: json['position'],
      status: json['status'],
      photo: json['photo'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}