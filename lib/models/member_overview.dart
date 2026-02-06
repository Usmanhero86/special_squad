class MemberOverview {
  final int totalMembers;
  final int activeMembers;
  final int inactiveMembers;
  final int suspendedMembers;

  MemberOverview({
    required this.totalMembers,
    required this.activeMembers,
    required this.inactiveMembers,
    required this.suspendedMembers,
  });

  factory MemberOverview.fromJson(Map<String, dynamic> json) {
    return MemberOverview(
      totalMembers: json['totalMembers'] ?? 0,
      activeMembers: json['activeMembers'] ?? 0,
      inactiveMembers: json['inactiveMembers'] ?? 0,
      suspendedMembers: json['suspendedMembers'] ?? 0,
    );
  }
}