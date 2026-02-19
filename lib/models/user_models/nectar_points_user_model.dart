import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/enums/achievements_enum.dart';
import 'package:flutter_app/models/group_models/hive.dart';
import 'package:flutter_app/models/user_models/app_user.dart';
import 'package:flutter_app/models/user_models/notifications_user_model.dart';
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

//This is the model for the nectar points snippets in the hive page
class NectarPointsUserModel{
  int? numIconsEarned;
  List<Achievements>? achievementsEarned; //List of the achievements earned, which can be used to display the achievements in the profile page
  int? numPointsEarned;
  //String is for the icon photoURL
  Hive? popularHive; //Hive in which the user has earned the most appreciation points, which can be used to display the hive in the home page as a spotlight
  AppUser? mostHelped; //User who has received the most appreciation points from the user, which can be used to display the user in the home page as a spotlight

  NectarPointsUserModel({
    this.numIconsEarned,
    this.achievementsEarned,
    this.numPointsEarned,
    this.popularHive,
    this.mostHelped
  });

  Map<String, dynamic> toMap() {
    return {
      'numIconsEarned': numIconsEarned,
      'achievementsEarned': achievementsEarned?.map((achievement) => achievement.toString()).toList(),
      'numPointsEarned': numPointsEarned,
      'popularHive': popularHive?.toMap(),
      'mostHelped': mostHelped?.toMap(),
    };
  }
}
