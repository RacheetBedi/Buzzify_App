import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/models/user_models/app_user.dart';
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

class HiveDefaultSettingsModel{
  bool additionEnabled;
  bool appreciationEnabled;
  bool logEnabled; //Hive notifications in the recent changes activity log
  bool taskRemovalEnabled;
  bool summaryEnabled;
  bool tradingEnabled;

  HiveDefaultSettingsModel({
    required this.additionEnabled,
    required this.appreciationEnabled,
    required this.logEnabled,
    required this.taskRemovalEnabled,
    required this.summaryEnabled,
    required this.tradingEnabled
  }); 

  Map<String, dynamic> toMap() {
    return {
      'additionEnabled': additionEnabled,
      'appreciationEnabled': appreciationEnabled,
      'logEnabled': logEnabled,
      'taskRemovalEnabled': taskRemovalEnabled,
      'summaryEnabled': summaryEnabled,
      'tradingEnabled': tradingEnabled
    };
  }

  factory HiveDefaultSettingsModel.fromMap(Map<String, dynamic> map) {
    return HiveDefaultSettingsModel(
      additionEnabled: map['additionEnabled'] ?? false,
      appreciationEnabled: map['appreciationEnabled'] ?? false,
      logEnabled: map['logEnabled'] ?? false,
      taskRemovalEnabled: map['taskRemovalEnabled'] ?? false,
      summaryEnabled: map['summaryEnabled'] ?? false,
      tradingEnabled: map['tradingEnabled'] ?? false
    );
  }

  
}