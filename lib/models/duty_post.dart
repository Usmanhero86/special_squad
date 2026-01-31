class DutyPost {
  String id;
  String name;
  String? description;
  String? location;

  DutyPost({required this.id, required this.name, this.description, this.location,});

  factory DutyPost.fromMap(Map<String, dynamic> data, String id) {
    return DutyPost(
      id: id,
      name: data['name'] ?? '',
      description: data['description'],
      location: data['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  DutyPost copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
  }) {
    return DutyPost(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
    );
  }
}
