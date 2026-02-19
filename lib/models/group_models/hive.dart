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
  String hive_subject;
  String? hive_code;
  String? points_description;
  String? icon_description;
  //Map of tasks can only be coded when the task model object is coded
  HiveDefaultSettingsModel? default_settings; //Replace this with a list of defaultSettingModelObjects later when the model is actually coded
  bool teacher_led;
  Color theme_color;
  String? hiveImage;
  NectarPointsDefaultSettingsModel? nectar_points_settings;
  List<NectarPointsUserModel>? nectar_snippet;
  List<NectarPointsUserModel>? nectar_points_total; //This is a separate snippet for teachers, which will be used in the teacher's pet achievement. It will be separate from the regular appreciation snippet, which is used for the extrovert achievement. This is because the teacher's pet achievement requires a certain number of points from teachers, so it makes sense to have a separate snippet for that.
  List<TaskModel>? tasks_snippet; //Replace this with a list of taskModelObjects later when the model is actually coded
  //Replace this with a list of appreciationSnippetModelObjects later when the model is actually coded

  //Each set of recent updates corresponds to 3 days of updates
  //A maximum of ten sets are stored
  List<NotificationsUserModel>? recent_updates; //Max should be ten
  List<AppUser>? hive_users; //Document has a limit of ~2,800 users, which should be more then enough.

  //Assigned tasks and completed tasks documents will be subcollections of the hive page, referenced by the tasks subcollection.
  //Under assigned/completed tasks, there will be multiple subcollections; each one will reference sets of tasks, automatically sorted by creation. 
  //Each subcollection references a document with a set of ~100 tasks, with earlier ones created before.
  List<TaskModel>? assigned_tasks; //Replace the data type with the task object later
  List<TaskModel>? completed_tasks; //Replace the data type with the task object later

  //On initialization, only ~10 assigned, to the current user, and ~5 completed, will be loaded. For more, there will be a load more button.

  Hive({
    this.hiveUid,
    this.hiveCreator,
    required this.userRole,
    required this.hiveName,
    required this.hiveDescription,
    required this.hive_subject,
    this.hive_code,
    this.points_description,
    this.icon_description,
    required this.default_settings,
    required this.teacher_led,
    required this.theme_color,
    this.hiveImage,
    this.nectar_points_settings,
    this.nectar_snippet,
    this.nectar_points_total,
    this.recent_updates,
    this.hive_users,
    this.assigned_tasks,
    this.completed_tasks,
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
      'hive_subject': hive_subject,
      'hive_code': hive_code,
      'points_description': points_description,
      'icon_description': icon_description,
      'default_settings': default_settings?.toMap(),
      'teacher_led': teacher_led,
      'theme_color': theme_color,
      'hiveImage': hiveImage,
      'nectar_points_settings': nectar_points_settings?.toMap(),
      // For lists, we need to convert each item to a map
      'nectar_snippet': nectar_snippet?.map((item) => item.toMap()).toList(),
      'nectar_points_total': nectar_points_total?.map((item) => item.toMap()).toList(),
      'recent_updates': recent_updates?.map((item) => item.toMap()).toList(),
      'hive_users': hive_users?.map((user) => user.toMap()).toList(),
      'assigned_tasks': assigned_tasks?.map((task) => task.toMap()).toList(),
      'completed_tasks': completed_tasks?.map((task) => task.toMap()).toList(),
    };
  }

  factory Hive.fromMap(Map<String, dynamic> map) {
    return Hive(
      hiveUid: map['hive_uid'],
      hiveName: map['hive_name'] ?? '',
      userRole: map['user_role'] ?? '',
      hiveDescription: map['hive_description'] ?? '',
      hive_subject: map['hive_subject'] ?? '',
      default_settings: null, 
      teacher_led: map['teacher_led'] ?? false,
      theme_color: map['theme_color'] != null ? Color(map['theme_color']) : Colors.blue, // Default to blue if no color is provided
    );
  }
}