class DutyMember {
  final String id;
  final String fullName;
  final String rifleNo;
  final String position;
  final String status;
  final String location;
  final String? photo;

  DutyMember({
    required this.id,
    required this.fullName,
    required this.rifleNo,
    required this.position,
    required this.status,
    required this.location,
    this.photo,
  });

  factory DutyMember.fromJson(Map<String, dynamic> json) {
    return DutyMember(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      rifleNo: json['rifleNo'] ?? '',
      position: json['position'] ?? '',
      status: json['status'] ?? '',
      location: json['location'] ?? '',
      photo: json['photo'],
    );
  }
}
