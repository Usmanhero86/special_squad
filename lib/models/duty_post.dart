class DutyPost {
  final String id;
  final String name;
  final String? description;
  final List<dynamic>? dutyAssignments; // List of duty assignments

  DutyPost({
    required this.id,
    required this.name,
    this.description,
    this.dutyAssignments,
  });

  factory DutyPost.fromJson(Map<String, dynamic> json) {
    return DutyPost(
      id: json['id'] ?? '',
      name: json['postName'] ?? '',
      description: json['description'],
      dutyAssignments: json['dutyAssignments'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postName': name,
      'description': description,
      if (dutyAssignments != null) 'dutyAssignments': dutyAssignments,
    };
  }
}
