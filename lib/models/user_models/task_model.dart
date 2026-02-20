import 'package:flutter_app/models/user_models/app_user.dart';

class TaskModel {
  String taskName;
  bool tradeable;
  DateTime dateAssigned;
  //Date assigned is immutable. If you want to change it, create a new task.
  DateTime dateDue;
  String taskType;
  String taskDescription;
  DateTime? dateCompleted;
  List<AppUser> usersTasked; //Instead of the first string, something indicating the users should be included; uid is a good option.
  // Structure is Map<uid, role>, where "role" indicates if the user is "creator", "task/project leader", "contributor", or the rare role of "spectator"
  // This structure allows for role-based permissions and consistency across tasks and projects.
  String hiveUiD;
  String hiveName;
  String difficulty;
  bool helpFlagged;
  String helpDetails;
  bool gcTask;
  String taskProgress;
  Map<dynamic, String>? images;


  TaskModel({
    required this.taskName,
    required this.tradeable,
    required this.dateAssigned,
    required this.dateDue,
    required this.taskType,
    required this.taskDescription,
    this.dateCompleted,
    required this.usersTasked,
    required this.hiveUiD,
    required this.hiveName,
    required this.difficulty,
    this.helpFlagged = false,
    this.helpDetails = '',
    required this.gcTask,
    this.taskProgress = 'unstarted',
    this.images,
  });

  List<dynamic> taskSnippet(){
    return [
      taskName,
      dateAssigned,
      dateDue,
      usersTasked,
      difficulty,
      helpFlagged,
      gcTask,
      taskProgress,
    ];
  }

  void changeName(String newName){
    taskName = newName;
  }

  void setTradeable (bool isTradeable){
    tradeable = isTradeable;
  }

  void setDueDate (DateTime newDueDate){
    dateDue = newDueDate;
  }

  void setTaskDescription (String newDescription){
    taskDescription = newDescription;
  }

  void setDateCompleted (DateTime completionDate){
    dateCompleted = completionDate;
  }

  void addUsersTasked (AppUser user){
    usersTasked.add(user);
  }

  void removeUsersTasked (AppUser user){
    usersTasked.remove(user);
  }

  void setDifficulty (String newDifficulty){
    difficulty = newDifficulty;
  }

  void setHelpFlagged (bool isHelpFlagged){
    helpFlagged = isHelpFlagged;
    if(isHelpFlagged){
      setHelpDetails("");
    }
  }

  void setHelpDetails (String newHelpDetails){
    helpDetails = newHelpDetails;
  }

  void isGCTask (bool isGC){
    gcTask = isGC;
    //If this is a Google Classroom task, we would want to reference the google classroom api page, which is coded late (not yet implemented)
  }

  void setTaskProgress (String newProgress){
    taskProgress = newProgress;
  }

  Map<String, dynamic> toMap() {
    return {
      'task_name': taskName,
      'tradeable': tradeable,
      'date_assigned': dateAssigned,
      'date_due': dateDue,
      'taskType': taskType,
      'task_description': taskDescription,
      'date_completed': dateCompleted,
      'users_tasked': usersTasked.map((user) => user.toMap()).toList(),
      'hive_ID': hiveUiD,
      'hive_name': hiveName,
      'difficulty': difficulty,
      'help_flagged': helpFlagged,
      'help_details': helpDetails,
      'gc_task': gcTask,
      'task_progress': taskProgress,
      'images': images
    };
  }
}