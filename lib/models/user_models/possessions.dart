import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/models/group_models/hive.dart';
import 'package:flutter_app/models/user_models/app_user.dart';
import 'package:flutter_app/models/user_models/nectar_points_personal_model.dart';
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