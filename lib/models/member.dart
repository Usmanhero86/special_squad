class Member {
  String id;
  String fullName;
  String rifleNumber;
  String phone;
  DateTime dateOfBirth;
  String address;
  String position;
  DateTime joinDate;
  String? profileImage;
  bool isActive;
  String? location;
  Map<String, dynamic>? additionalInfo;

  Member({
    required this.id,
    required this.fullName,
    required this.rifleNumber,
    required this.phone,
    required this.dateOfBirth,
    required this.address,
    required this.position,
    required this.joinDate,
    this.profileImage,
    this.isActive = true,
    this.additionalInfo,
    this.location,

  });

  factory Member.fromMap(Map<String, dynamic> data, String id) {
    return Member(
      id: id,
      fullName: data['fullName'] ?? '',
      rifleNumber: data['rifleNumber'] ?? '', 
      phone: data['phone'] ?? '',
      dateOfBirth: DateTime.fromMillisecondsSinceEpoch(data['dateOfBirth']),
      address: data['address'] ?? '',
      position: data['position'] ?? 'Member',
      joinDate: DateTime.fromMillisecondsSinceEpoch(data['joinDate']),
      profileImage: data['profileImage'],
      isActive: data['isActive'] ?? true,
      additionalInfo: data['additionalInfo'],
      location: data['location']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'rifleNumber': rifleNumber,
      'phone': phone,
      'dateOfBirth': dateOfBirth.millisecondsSinceEpoch,
      'address': address,
      'position': position,
      'joinDate': joinDate.millisecondsSinceEpoch,
      'profileImage': profileImage,
      'isActive': isActive,
      'additionalInfo': additionalInfo,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'location': location
    };
  }

  // Add getter for compatibility
  String get idNumber => rifleNumber;

  // Updated copyWith method
  Member copyWith({
    String? id,
    String? fullName,
    String? rifleNumber,
    String? phone,
    DateTime? dateOfBirth,
    String? address,
    String? position,
    DateTime? joinDate,
    String? profileImage,
    bool? isActive,
    Map<String, dynamic>? additionalInfo,
    String? location,
  }) {
    return Member(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      rifleNumber: rifleNumber ?? this.rifleNumber,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      position: position ?? this.position,
      joinDate: joinDate ?? this.joinDate,
      profileImage: profileImage ?? this.profileImage,
      isActive: isActive ?? this.isActive,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      location: location?? this.location
    );
  }
}