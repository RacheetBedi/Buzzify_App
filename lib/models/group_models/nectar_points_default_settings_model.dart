
class NectarPointsDefaultSettingsModel {
 bool? iconsTradeable;
 bool? leaderboardEnabled;
 bool? pointsTradeable;

 NectarPointsDefaultSettingsModel({
  this.iconsTradeable,
  this.leaderboardEnabled,
  this.pointsTradeable,
 });

 Map<String, dynamic> toMap() {
  return {
   'icons_tradeable': iconsTradeable,
   'leaderboard_enabled': leaderboardEnabled,
   'points_tradeable': pointsTradeable,
  };
 }
}