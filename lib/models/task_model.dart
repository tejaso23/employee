class TaskModel {
  String id, uid;
  final String taskTitle, taskType, startDateTime, duration;

  TaskModel(
      {required this.id,
      required this.uid,
      required this.taskTitle,
      required this.taskType,
      required this.startDateTime,
      required this.duration});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "uid": uid,
      "taskTitle": taskTitle,
      "taskType": taskType,
      "startDateTime": startDateTime,
      "duration": duration,
    };
  }
}
