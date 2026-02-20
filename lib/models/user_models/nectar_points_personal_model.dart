import 'package:flutter_app/enums/achievements_enum.dart';
import 'package:flutter_app/models/group_models/hive.dart';

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