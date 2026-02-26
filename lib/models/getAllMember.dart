class Members {
  final String id;
  final String fullName;
  final String rifleNo;
  final String position;
  final String status;
  final String? location;
  final String? photo;

  Members({
    required this.id,
    required this.fullName,
    required this.rifleNo,
    required this.position,
    required this.status,
    this.location,
    this.photo,
  });

  bool get isActive => status == 'ACTIVE';

  factory Members.fromJson(Map<String, dynamic> json) {
    return Members(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? 'Unknown',
      rifleNo: json['rifleNo'] ?? '',
      position: json['position'] ?? 'Member',
      status: json['status'] ?? 'ACTIVE',
      location: json['location'],
      photo: json['photo'],
    );
  }
}
