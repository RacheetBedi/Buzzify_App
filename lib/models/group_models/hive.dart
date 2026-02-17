import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/models/group_models/hive_default_settings_model.dart';
import 'package:flutter_app/models/group_models/nectar_points_default_settings_model.dart';
import 'package:flutter_app/models/user_models/app_user.dart';
import 'package:flutter_app/models/user_models/nectar_points_user_model.dart';
import 'package:flutter_app/models/user_models/notifications_user_model.dart';
import 'package:flutter_app/models/user_models/task_model.dart';
import 'package:flutter_app/pages/Setup_Pages/login_page.dart';
import 'package:flutter_app/providers/google_auth_service_provider.dart';
import 'package:flutter_app/utilities/theme.dart';
import 'package:flutter_app/routing/wrapper.dart';
import 'package:flutter_app/utilities/userRepository.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/instance_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  String? hive_uid;
  AppUser? hive_creator;
  String user_role;
  String hive_name;
  String hive_description;
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
  List<NectarPointsUserModel>? appreciation_snippet;
  List<NectarPointsUserModel>? appreciation_points_total; //This is a separate snippet for teachers, which will be used in the teacher's pet achievement. It will be separate from the regular appreciation snippet, which is used for the extrovert achievement. This is because the teacher's pet achievement requires a certain number of points from teachers, so it makes sense to have a separate snippet for that.
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
    this.hive_uid,
    this.hive_creator,
    required this.user_role,
    required this.hive_name,
    required this.hive_description,
    required this.hive_subject,
    this.hive_code,
    this.points_description,
    this.icon_description,
    required this.default_settings,
    required this.teacher_led,
    required this.theme_color,
    this.hiveImage,
    this.nectar_points_settings,
    this.appreciation_snippet,
    this.appreciation_points_total,
    this.recent_updates,
    this.hive_users,
    this.assigned_tasks,
    this.completed_tasks,
  });

  Map<String, dynamic> toMap() {
    return {
      'hive_uid': hive_uid,
      'hive_creator': hive_creator?.toMap(),
      'user_role': user_role,
      'hive_name': hive_name,
      'hive_description': hive_description,
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
      'nectar_snippet': appreciation_snippet?.map((item) => item.toMap()).toList(),
      'nectar_points_total': appreciation_points_total?.map((item) => item.toMap()).toList(),
      'recent_updates': recent_updates?.map((item) => item.toMap()).toList(),
      'hive_users': hive_users?.map((user) => user.toMap()).toList(),
      'assigned_tasks': assigned_tasks?.map((task) => task.toMap()).toList(),
      'completed_tasks': completed_tasks?.map((task) => task.toMap()).toList(),
    };
  }
}