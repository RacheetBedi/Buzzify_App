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

class TaskModel {
  String task_name;
  bool tradeable;
  DateTime date_assigned;
  //Date assigned is immutable. If you want to change it, create a new task.
  DateTime date_due;
  String taskType;
  String task_description;
  DateTime? date_completed;
  List<AppUser> users_tasked; //Instead of the first string, something indicating the users should be included; uid is a good option.
  // Structure is Map<uid, role>, where "role" indicates if the user is "creator", "task/project leader", "contributor", or the rare role of "spectator"
  // This structure allows for role-based permissions and consistency across tasks and projects.
  String hive_ID;
  String hive_name;
  String difficulty;
  bool help_flagged;
  String help_details;
  bool gc_task;
  String task_progress;
  Map<dynamic, String>? images;


  TaskModel({
    required this.task_name,
    required this.tradeable,
    required this.date_assigned,
    required this.date_due,
    required this.taskType,
    required this.task_description,
    this.date_completed,
    required this.users_tasked,
    required this.hive_ID,
    required this.hive_name,
    required this.difficulty,
    this.help_flagged = false,
    this.help_details = '',
    required this.gc_task,
    this.task_progress = 'unstarted',
    this.images,
  });

  List<dynamic> taskSnippet(){
    return [
      task_name,
      date_assigned,
      date_due,
      users_tasked,
      difficulty,
      help_flagged,
      gc_task,
      task_progress,
    ];
  }

  void changeName(String newName){
    task_name = newName;
  }

  void setTradeable (bool isTradeable){
    tradeable = isTradeable;
  }

  void setDueDate (DateTime newDueDate){
    date_due = newDueDate;
  }

  void setTaskDescription (String newDescription){
    task_description = newDescription;
  }

  void setDateCompleted (DateTime completionDate){
    date_completed = completionDate;
  }

  void addUsersTasked (AppUser user){
    users_tasked.add(user);
  }

  void removeUsersTasked (AppUser user){
    users_tasked.remove(user);
  }

  void setDifficulty (String newDifficulty){
    difficulty = newDifficulty;
  }

  void setHelpFlagged (bool isHelpFlagged){
    help_flagged = isHelpFlagged;
    if(isHelpFlagged){
      setHelpDetails("");
    }
  }

  void setHelpDetails (String newHelpDetails){
    help_details = newHelpDetails;
  }

  void isGCTask (bool isGC){
    gc_task = isGC;
    //If this is a Google Classroom task, we would want to reference the google classroom api page, which is coded late (not yet implemented)
  }

  void setTaskProgress (String newProgress){
    task_progress = newProgress;
  }

  Map<String, dynamic> toMap() {
    return {
      'task_name': task_name,
      'tradeable': tradeable,
      'date_assigned': date_assigned,
      'date_due': date_due,
      'taskType': taskType,
      'task_description': task_description,
      'date_completed': date_completed,
      'users_tasked': users_tasked.map((user) => user.toMap()).toList(),
      'hive_ID': hive_ID,
      'hive_name': hive_name,
      'difficulty': difficulty,
      'help_flagged': help_flagged,
      'help_details': help_details,
      'gc_task': gc_task,
      'task_progress': task_progress,
      'images': images
    };
  }
}