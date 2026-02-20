import 'package:flutter_app/enums/achievements_enum.dart';
import 'package:flutter_app/models/group_models/hive.dart';
import 'package:flutter_app/models/user_models/app_user.dart';

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
