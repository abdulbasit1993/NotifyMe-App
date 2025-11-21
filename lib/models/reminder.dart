class Reminder {
  final String id;
  final String title;
  final DateTime dateTime;
  final int notificationId;

  Reminder({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.notificationId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'notificationId': notificationId,
    };
  }

  static Reminder fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as String,
      title: map['title'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      notificationId: map['notificationId'] as int,
    );
  }
}
