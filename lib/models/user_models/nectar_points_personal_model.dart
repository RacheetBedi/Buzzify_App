import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/enums/achievements_enum.dart';
import 'package:flutter_app/models/group_models/hive.dart';
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

//This is the model for the nectar points details stored by each person, throughout their lifetime in using the app.
class NectarPointsPersonalModel{
  List<Achievements>? allAchievementsEarned;
  List<Achievements>? allGoogleClassroomAchievementsEarned;
  int? numPointsEarned;
  int? numAchivementsEarned;
  int? numPeopleHelped;
  Hive? hiveMostHelped;

  NectarPointsPersonalModel({
    this.allAchievementsEarned,
    this.allGoogleClassroomAchievementsEarned,
    this.numPointsEarned,
    this.numAchivementsEarned,
    this.numPeopleHelped,
    this.hiveMostHelped,
  });

  Map<String, dynamic> toMap() {
    return {
      'allAchievementsEarned': allAchievementsEarned?.map((achievement) => achievement.toString()).toList(),
      'allGoogleClassroomAchievementsEarned': allGoogleClassroomAchievementsEarned?.map((achievement) => achievement.toString()).toList(),
      'numPointsEarned': numPointsEarned,
      'numAchivementsEarned': numAchivementsEarned,
      'numPeopleHelped': numPeopleHelped,
      'hiveMostHelped': hiveMostHelped?.toMap(),
    };
  }
}