class DutyRoster {
  String id;
  String memberId;
  String dutyPostId;
  DateTime date;
  String shift; 
  String status;
  String? notes;

  DutyRoster({
    required this.id,
    required this.memberId,
    required this.dutyPostId,
    required this.date,
    required this.shift,
    this.status = 'Scheduled',
    this.notes,
  });
}