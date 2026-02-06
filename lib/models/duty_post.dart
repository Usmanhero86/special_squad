class DutyPost {
  final String id;
  final String name;
  final String? description;

  DutyPost({
    required this.id,
    required this.name,
    this.description,
  });

  factory DutyPost.fromJson(Map<String, dynamic> json) {
    return DutyPost(
      id: json['id'] ?? '',
      name: json['postName'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postName': name,
      'description': description,
    };
  }
}