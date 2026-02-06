class Location {
  final String id;
  final String name;
  final String? address;

  Location({
    required this.id,
    required this.name,
    this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      address: json['address'],
    );
  }
}