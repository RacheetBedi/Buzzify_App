import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/enums/achievements_enum.dart';
import 'package:flutter_app/models/group_models/hive.dart';
import 'package:flutter_app/models/user_models/app_user.dart';
import 'package:hive_flutter/adapters.dart' as type_adapter;

class NotificationsUserModel{
  DateTime? updateTime;
  String? briefDescription;
  Hive? hiveOccurred;
  AppUser? userResponsible;
  String? longerDescription;
  Achievements? achievementUnlocked; //Null if no achievement was unlocked, otherwise contains the achievement that was unlocked
  bool? helpedOthers;

  NotificationsUserModel({
    this.updateTime,
    this.briefDescription,
    this.hiveOccurred,
    this.userResponsible,
    this.longerDescription,
    this.achievementUnlocked,
    this.helpedOthers
  });

  Map<String, dynamic> toMap() {
    return {
      'updateTime': updateTime != null ? Timestamp.fromDate(updateTime!) : Timestamp.fromDate(DateTime.now()),
      'briefDescription': briefDescription ?? '',
      'longerDescription': longerDescription ?? '',
      'helpedOthers': helpedOthers ?? false,
      'achievementUnlocked': achievementUnlocked?.name ?? 'none',
      'user' : userResponsible?.toShortMap(),
      'hive': hiveOccurred?.toShortMap(),
    };
  }

  factory NotificationsUserModel.fromMap(Map<String, dynamic> map) {
    return NotificationsUserModel(
      updateTime: (map['updateTime'] as Timestamp?)?.toDate(),
      briefDescription: map['briefDescription'] as String?,
      longerDescription: map['longerDescription'] as String?,
      helpedOthers: map['helpedOthers'] as bool?,
      achievementUnlocked: map['achievementUnlocked'] != null ? Achievements.values.firstWhere((e) => e.name == map['achievementUnlocked']) : null,
      userResponsible: map['user'] != null
          ? AppUser.fromMap(map['user'])
          : null,
      hiveOccurred: map['hive'] != null
          ? Hive.fromMap(map['hive'])
          : null,
    );
  }
}

  class NotificationsUserModelAdapter extends type_adapter.TypeAdapter<NotificationsUserModel> {
  @override
  final int typeId = 0;

  @override
  NotificationsUserModel read(type_adapter.BinaryReader reader) {
    return NotificationsUserModel(
      updateTime: reader.read() as DateTime?,
      briefDescription: reader.read() as String?,
      longerDescription: reader.read() as String?,
      helpedOthers: reader.read() as bool?,
      achievementUnlocked: reader.read() != null ? Achievements.values.firstWhere((e) => e.name == reader.read()) : null,
      userResponsible: reader.read() != null
          ? AppUser.fromMap(reader.read())
          : null,
      hiveOccurred: reader.read() != null
          ? Hive.fromMap(reader.read())
          : null,
    );
  }

  @override
  void write(type_adapter.BinaryWriter writer, NotificationsUserModel obj) {
    writer.write(obj.updateTime);
    writer.write(obj.briefDescription);
    writer.write(obj.longerDescription);
    writer.write(obj.helpedOthers);
    writer.write(obj.achievementUnlocked?.name ?? 'none');
    if (obj.userResponsible != null) {
      writer.write(obj.userResponsible!.toMap());
    } else {
      writer.write(null);
    }
    if (obj.hiveOccurred != null) {
      writer.write(obj.hiveOccurred!.toShortMap());
    } else {
      writer.write(null);
    }
  }
  }
