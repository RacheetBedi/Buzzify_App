
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
      'tradingEnabled': tradingEnabled,
    };
  }

  factory HiveDefaultSettingsModel.fromMap(Map<String, dynamic> map) {
    return HiveDefaultSettingsModel(
      additionEnabled: map['additionEnabled'] ?? false,
      appreciationEnabled: map['appreciationEnabled'] ?? false,
      logEnabled: map['logEnabled'] ?? false,
      taskRemovalEnabled: map['taskRemovalEnabled'] ?? false,
      summaryEnabled: map['summaryEnabled'] ?? false,
      tradingEnabled: map['tradingEnabled'] ?? false,
    );
  }
}