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
  final String tribe;
  final String religion;
  final String gender;
  final String permanentAddress;
  final String maritalStatus;
  final String ninNo;
  final String bvnNo;
  final String state;
  final String accountNo;
  final String unitArea;
  final String unitAreaType;
  final String guarantorFullName;
  final String guarantorRelationship;
  final String guarantorTribe;
  final String guarantorPhoneNumber;
  final String emergencyFullName;
  final String emergencyAddress;
  final String emergencyPhoneNumber;
  final String nextOfKinFullName;
  final String nextOfKinAddress;
  final String nextOfKinPhoneNumber;

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
    required this.tribe,
    required this.religion,
    required this.gender,
    required this.permanentAddress,
    required this.maritalStatus,
    required this.ninNo,
    required this.bvnNo,
    required this.state,
    required this.accountNo,
    required this.unitArea,
    required this.unitAreaType,
    required this.guarantorFullName,
    required this.guarantorRelationship,
    required this.guarantorTribe,
    required this.guarantorPhoneNumber,
    required this.emergencyFullName,
    required this.emergencyAddress,
    required this.emergencyPhoneNumber,
    required this.nextOfKinFullName,
    required this.nextOfKinAddress,
    required this.nextOfKinPhoneNumber,
  });

  /// ✅ ADD IT RIGHT HERE
  bool get isActive => status.toUpperCase() == 'ACTIVE';

  factory MemberDetail.fromJson(Map<String, dynamic> json) {
    return MemberDetail(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      idNo: json['idNo'] ?? '',
      rifleNo: json['rifleNo'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      location: json['location'] ?? '',
      position: json['position'] ?? '',
      status: json['status'] ?? 'ACTIVE',
      photo: json['photo'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      createdAt: DateTime.parse(json['createdAt']),
      tribe: json['tribe'] ?? '',
      religion: json['religion'] ?? '',
      gender: json['gender'] ?? 'Male',
      permanentAddress: json['permanentAddress'] ?? '',
      maritalStatus: json['maritalStatus'] ?? '',
      ninNo: json['ninNo'] ?? '',
      bvnNo: json['bvnNo'] ?? '',
      state: json['state'] ?? '',
      accountNo: json['accountNo'] ?? '',
      unitArea: json['unitArea'] ?? '',
      unitAreaType: json['unitAreaType'] ?? '',
      guarantorFullName: json['guarantorFullName'] ?? '',
      guarantorRelationship: json['guarantorRelationship'] ?? '',
      guarantorTribe: json['guarantorTribe'] ?? '',
      guarantorPhoneNumber: json['guarantorPhoneNumber'] ?? '',
      emergencyFullName: json['emergencyFullName'] ?? '',
      emergencyAddress: json['emergencyAddress'] ?? '',
      emergencyPhoneNumber: json['emergencyPhoneNumber'] ?? '',
      nextOfKinFullName: json['nextOfKinFullName'] ?? '',
      nextOfKinAddress: json['nextOfKinAddress'] ?? '',
      nextOfKinPhoneNumber: json['nextOfKinPhoneNumber'] ?? '',
    );
  }
}
