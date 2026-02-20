import 'package:flutter_app/models/group_models/hive.dart';
import 'package:flutter_app/models/user_models/nectar_points_personal_model.dart';
import 'package:flutter_app/models/user_models/notifications_user_model.dart';
import 'package:flutter_app/models/user_models/task_model.dart';

class Possessions {
  List<NotificationsUserModel>? userNotificationLog;
  List<Map<String, dynamic>>? userNotificationLogMap;
  List<TaskModel>? upcomingTasks;
  NectarPointsPersonalModel? nectarPoints;
  List<Hive>? hivesJoined;

  Possessions({
    this.userNotificationLog,
    this.upcomingTasks,
    this.nectarPoints,
    this.hivesJoined,
  }){
    if (userNotificationLog != null) {
      userNotificationLogMap = userNotificationLog!.map((notification) => notification.toMap()).toList();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'userNotificationLog': userNotificationLogMap,
      'upcomingTasks': upcomingTasks?.map((task) => task.toMap()).toList(),
      'nectarPoints': nectarPoints?.toMap(),
      'hivesJoined': hivesJoined?.map((hive) => hive.toMap()).toList(),
    };
  }
}