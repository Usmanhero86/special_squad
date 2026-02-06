class DutyAssignment {
  final String memberId;
  final AssignedMember member;
  final String day;
  final String assignmentId;

  DutyAssignment({
    required this.memberId,
    required this.member,
    required this.day,
    required this.assignmentId,
  });

  factory DutyAssignment.fromJson(Map<String, dynamic> json) {
    return DutyAssignment(
      memberId: json['memberId'] ?? '',
      member: AssignedMember.fromJson(json['member'] ?? {}),
      day: json['day'] ?? '',
      assignmentId: json['assignmentId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'member': member.toJson(),
      'day': day,
      'assignmentId': assignmentId,
    };
  }
}

class AssignedMember {
  final String id;
  final String fullName;
  final String? idNo;
  final String? rifleNo;
  final String? tribe;
  final String? religion;
  final String? dateOfBirth;
  final String? phoneNumber;
  final String? locationId;
  final String? gender;
  final String? permanentAddress;
  final String? maritalStatus;
  final String? position;
  final String? ninNo;
  final String? state;
  final String? accountNo;
  final String? unitArea;
  final String? unitAreaType;
  final String? photo;
  final String? guarantorFullName;
  final String? guarantorRelationship;
  final String? guarantorTribe;
  final String? guarantorPhoneNumber;
  final String? emergencyFullName;
  final String? emergencyAddress;
  final String? emergencyPhoneNumber;
  final String? nextOfKinFullName;
  final String? nextOfKinAddress;
  final String? nextOfKinPhoneNumber;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final String? dutyPostId;

  AssignedMember({
    required this.id,
    required this.fullName,
    this.idNo,
    this.rifleNo,
    this.tribe,
    this.religion,
    this.dateOfBirth,
    this.phoneNumber,
    this.locationId,
    this.gender,
    this.permanentAddress,
    this.maritalStatus,
    this.position,
    this.ninNo,
    this.state,
    this.accountNo,
    this.unitArea,
    this.unitAreaType,
    this.photo,
    this.guarantorFullName,
    this.guarantorRelationship,
    this.guarantorTribe,
    this.guarantorPhoneNumber,
    this.emergencyFullName,
    this.emergencyAddress,
    this.emergencyPhoneNumber,
    this.nextOfKinFullName,
    this.nextOfKinAddress,
    this.nextOfKinPhoneNumber,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.dutyPostId,
  });

  factory AssignedMember.fromJson(Map<String, dynamic> json) {
    return AssignedMember(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      idNo: json['idNo'],
      rifleNo: json['rifleNo'],
      tribe: json['tribe'],
      religion: json['religion'],
      dateOfBirth: json['dateOfBirth'],
      phoneNumber: json['phoneNumber'],
      locationId: json['locationId'],
      gender: json['gender'],
      permanentAddress: json['permanentAddress'],
      maritalStatus: json['maritalStatus'],
      position: json['position'],
      ninNo: json['ninNo'],
      state: json['state'],
      accountNo: json['accountNo'],
      unitArea: json['unitArea'],
      unitAreaType: json['unitAreaType'],
      photo: json['photo'],
      guarantorFullName: json['guarantorFullName'],
      guarantorRelationship: json['guarantorRelationship'],
      guarantorTribe: json['guarantorTribe'],
      guarantorPhoneNumber: json['guarantorPhoneNumber'],
      emergencyFullName: json['emergencyFullName'],
      emergencyAddress: json['emergencyAddress'],
      emergencyPhoneNumber: json['emergencyPhoneNumber'],
      nextOfKinFullName: json['nextOfKinFullName'],
      nextOfKinAddress: json['nextOfKinAddress'],
      nextOfKinPhoneNumber: json['nextOfKinPhoneNumber'],
      status: json['status'] ?? 'ACTIVE',
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      dutyPostId: json['dutyPostId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'idNo': idNo,
      'rifleNo': rifleNo,
      'tribe': tribe,
      'religion': religion,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'locationId': locationId,
      'gender': gender,
      'permanentAddress': permanentAddress,
      'maritalStatus': maritalStatus,
      'position': position,
      'ninNo': ninNo,
      'state': state,
      'accountNo': accountNo,
      'unitArea': unitArea,
      'unitAreaType': unitAreaType,
      'photo': photo,
      'guarantorFullName': guarantorFullName,
      'guarantorRelationship': guarantorRelationship,
      'guarantorTribe': guarantorTribe,
      'guarantorPhoneNumber': guarantorPhoneNumber,
      'emergencyFullName': emergencyFullName,
      'emergencyAddress': emergencyAddress,
      'emergencyPhoneNumber': emergencyPhoneNumber,
      'nextOfKinFullName': nextOfKinFullName,
      'nextOfKinAddress': nextOfKinAddress,
      'nextOfKinPhoneNumber': nextOfKinPhoneNumber,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'dutyPostId': dutyPostId,
    };
  }

  DateTime? get dateOfBirthParsed {
    if (dateOfBirth == null) return null;
    try {
      return DateTime.parse(dateOfBirth!);
    } catch (e) {
      return null;
    }
  }

  String get displayPhoto => photo ?? '';
  bool get hasPhoto => photo != null && photo!.isNotEmpty;
}
