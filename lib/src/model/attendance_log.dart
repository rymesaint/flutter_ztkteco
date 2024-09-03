class AttendanceLog {
  final int? uid;
  final String? id;
  final int? state;
  final String? timestamp;
  final int? type;

  const AttendanceLog({
    this.uid,
    this.id,
    this.state,
    this.timestamp,
    this.type,
  });

  factory AttendanceLog.fromJson(Map<String, dynamic> json) => AttendanceLog(
        uid: json['uid'],
        id: json['id'],
        state: json['state'],
        timestamp: json['timestamp'],
        type: json['type'],
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'id': id,
        'state': state,
        'timestamp': timestamp,
        'type': type,
      };

  @override
  String toString() {
    return 'AttendanceLog(uid: $uid, id: $id, state: $state, timestamp: $timestamp, type: $type)';
  }
}
