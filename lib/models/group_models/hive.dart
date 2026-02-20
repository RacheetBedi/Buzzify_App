import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/models/group_models/hive_default_settings_model.dart';
import 'package:flutter_app/models/group_models/nectar_points_default_settings_model.dart';
import 'package:flutter_app/models/user_models/app_user.dart';
import 'package:flutter_app/models/user_models/nectar_points_user_model.dart';
import 'package:flutter_app/models/user_models/notifications_user_model.dart';
import 'package:flutter_app/models/user_models/task_model.dart';

/*Two scenarios:

1. Hive is created from scratch. In this case, I want to call the following:
  1. HiveRepository, to make the hive document in Firestore
*/

/*

can I do this sort of structure for when I want to create my hives? for example, should I
use a new provider for hives, keeping track of the hive data, and use hiveProvider.createNewFirestoreHive
or something of the sort, which then references my hiveRepository? Or is this overly complex;
is riverpod useful for hives (which are my 'groups', similar to canvas classes).
*/

class Hive {
  String? hiveUid;
  AppUser? hiveCreator;
  String userRole;
  String hiveName;
  String hiveDescription;
  String hiveSubject;
  String? hiveCode;
  String? pointsDescription;
  String? iconDescription;
  //Map of tasks can only be coded when the task model object is coded
  HiveDefaultSettingsModel? defaultSettings; //Replace this with a list of defaultSettingModelObjects later when the model is actually coded
  bool teacherLed;
  Color themeColor;
  String? hiveImage;
  NectarPointsDefaultSettingsModel? nectarPointsSettings;
  List<NectarPointsUserModel>? nectarSnippet;
  List<NectarPointsUserModel>? nectarAchievementsTotal;
  List<TaskModel>? tasksSnippet; //Replace this with a list of taskModelObjects later when the model is actually coded
  //Replace this with a list of appreciationSnippetModelObjects later when the model is actually coded

  //Each set of recent updates corresponds to 3 days of updates
  //A maximum of ten sets are stored
  List<NotificationsUserModel>? recentUpdates; //Max should be ten
  List<AppUser>? hiveUsers; //Document has a limit of ~2,800 users, which should be more then enough.

  //Assigned tasks and completed tasks documents will be subcollections of the hive page, referenced by the tasks subcollection.
  //Under assigned/completed tasks, there will be multiple subcollections; each one will reference sets of tasks, automatically sorted by creation. 
  //Each subcollection references a document with a set of ~100 tasks, with earlier ones created before.
  List<TaskModel>? assignedTasks; //Replace the data type with the task object later
  List<TaskModel>? completedTasks; //Replace the data type with the task object later

  //On initialization, only ~10 assigned, to the current user, and ~5 completed, will be loaded. For more, there will be a load more button.

  Hive({
    this.hiveUid,
    this.hiveCreator,
    required this.userRole,
    required this.hiveName,
    required this.hiveDescription,
    required this.hiveSubject,
    this.hiveCode,
    this.pointsDescription,
    this.iconDescription,
    required this.defaultSettings,
    required this.teacherLed,
    required this.themeColor,
    this.hiveImage,
    this.nectarPointsSettings,
    this.nectarSnippet,
    this.nectarAchievementsTotal,
    this.recentUpdates,
    this.hiveUsers,
    this.assignedTasks,
    this.completedTasks,
    this.tasksSnippet,
  });

  Map<String, dynamic> toShortMap(){
    return {
      'hive_uid': hiveUid,
      'hive_name': hiveName,
      'hive_role' : userRole,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'hive_uid': hiveUid,
      'hive_creator': hiveCreator?.toMap(),
      'user_role': userRole,
      'hive_name': hiveName,
      'hive_description': hiveDescription,
      'hive_subject': hiveSubject,
      'hive_code': hiveCode,
      'points_description': pointsDescription,
      'icon_description': iconDescription,
      'default_settings': defaultSettings?.toMap(),
      'teacher_led': teacherLed,
      'theme_color': themeColor,
      'hiveImage': hiveImage,
      'nectar_points_settings': nectarPointsSettings?.toMap(),
      // For lists, we need to convert each item to a map
      'nectar_snippet': nectarSnippet?.map((item) => item.toMap()).toList(),
      'nectar_points_total': nectarAchievementsTotal?.map((item) => item.toMap()).toList(),
      'recent_updates': recentUpdates?.map((item) => item.toMap()).toList(),
      'hive_users': hiveUsers?.map((user) => user.toMap()).toList(),
      'assigned_tasks': assignedTasks?.map((task) => task.toMap()).toList(),
      'completed_tasks': completedTasks?.map((task) => task.toMap()).toList(),
    };
  }

  factory Hive.fromMap(Map<String, dynamic> map) {
    return Hive(
      hiveUid: map['hive_uid'],
      hiveName: map['hive_name'] ?? '',
      userRole: map['user_role'] ?? '',
      hiveDescription: map['hive_description'] ?? '',
      hiveSubject: map['hive_subject'] ?? '',
      defaultSettings: null, 
      teacherLed: map['teacher_led'] ?? false,
      themeColor: map['theme_color'] != null ? Color(map['theme_color']) : Colors.blue, // Default to blue if no color is provided
    );
  }
}