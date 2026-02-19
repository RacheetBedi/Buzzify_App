import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/group_models/hive.dart';
import 'package:flutter_app/models/user_models/nectar_points_personal_model.dart';
import 'package:flutter_app/models/user_models/nectar_points_user_model.dart';
import 'package:flutter_app/models/user_models/possessions.dart';
import 'package:flutter_app/models/user_models/notifications_user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class AppUser{
  String uid;
  bool? dark_mode;
  bool? is_teacher;
  String? lang;
  int? logoPref;
  String? password;
  int? country_code;
  String? displayFirstName;
  String? displayLastName;
  String? userName;
  String? email;
  String? photoURL;
  bool isEmailVerified;
  int? phoneNumber;
  bool hasCompletedSetup;
  String? description;
  String? school;
  Possessions? possessions;
  // List<RecentUpdateUserModel>? activity_log;
  // NectarPointsPersonalModel? appreciation_points;
  // List<Hive>? hives_joined;


  AppUser({
    required this.uid,
    this.displayFirstName,
    this.displayLastName,
    this.email,
    this.photoURL,
    this.isEmailVerified = false,
    this.phoneNumber,
    required this.hasCompletedSetup,
    this.description,
    this.dark_mode,
    this.is_teacher,
    this.lang,
    this.logoPref,
    this.password,
    this.country_code,
    this.userName,
    this.school,
    this.possessions,
  });

  factory AppUser.fromFirebaseUser(User user,{
    bool hasCompletedSetup = false,
    bool dark_mode = false,
    bool is_teacher = false,
    String lang = "EN",
    int logoPref = 1,
    String password = "",
    int country_code = 1,
    String userName = "",
    String description = "",
    String firstName = "",
    String lastName = "",
    String school = "",
    Possessions? possessions,
    }){
    return AppUser(
      uid: user.uid,
      displayFirstName: firstName,
      displayLastName: lastName,
      email: user.email,
      photoURL: user.photoURL,
      isEmailVerified: user.emailVerified,
      hasCompletedSetup: hasCompletedSetup,
      dark_mode: dark_mode,
      is_teacher: is_teacher,
      lang: lang,
      logoPref: logoPref,
      password: password,
      country_code: country_code,
      userName: userName,
      description: description,
      school: school,
      possessions: possessions,
    );
  }

  AppUser copyWith({
    String? displayName,
    String? email,
    String? photoURL,
    bool? isEmailVerified,
    bool? isNewUser,
    String? description,
    String? school,
    Possessions? possessions,
    //ADD OTHER PROPERTIES LATER HERE!
  }) {
    return AppUser(
      uid: this.uid,
      displayFirstName: displayFirstName ?? this.displayFirstName,
      displayLastName: displayLastName ?? this.displayLastName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      hasCompletedSetup: isNewUser ?? this.hasCompletedSetup,
      description: description ?? this.description,
      school: school ?? this.school,
      possessions: possessions ?? this.possessions,
    );
  }

  Map<String, dynamic> toShortMap(){
    return{
      'uid': uid,
      'displayFirstName': displayFirstName,
      'displayLastName': displayLastName,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayFirstName': displayFirstName,
      'displayLastName': displayLastName,
      'email': email,
      'photoURL': photoURL,
      'isEmailVerified': isEmailVerified,
      'phoneNumber': phoneNumber,
      'hasCompletedSetup': hasCompletedSetup,
      'description': description,
      'school': school,
      'possessions': possessions?.toMap(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      displayFirstName: map['displayFirstName'],
      displayLastName: map['displayLastName'],
      hasCompletedSetup: map['hasCompletedSetup'] ?? false,
    );
  }
}