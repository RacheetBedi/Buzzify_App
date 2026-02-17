import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/group_models/hive.dart';
import 'package:flutter_app/models/group_models/hive_default_settings_model.dart';
import 'package:flutter_app/models/user_models/app_user.dart';
import 'package:flutter_app/models/user_models/nectar_points_user_model.dart';
import 'package:flutter_app/models/user_models/notifications_user_model.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/hive_service_provider.dart';
import 'package:flutter_app/providers/hive_service_provider.dart';
import 'package:flutter_app/utilities/userRepository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class NectarPointsDefaultSettingsModel {
 bool? icons_tradeable;
 bool? leaderboard_enabled;
 bool? points_tradeable;

 NectarPointsDefaultSettingsModel({
  this.icons_tradeable,
  this.leaderboard_enabled,
  this.points_tradeable,
 });

 Map<String, dynamic> toMap() {
  return {
   'icons_tradeable': icons_tradeable,
   'leaderboard_enabled': leaderboard_enabled,
   'points_tradeable': points_tradeable,
  };
 }
}