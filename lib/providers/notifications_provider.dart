import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'package:hive_flutter/hive_flutter.dart';

final notificationsBoxProvider = FutureProvider<Box<NotificationsUserModel>>((ref) async {
  await Hive.initFlutter();
  Hive.registerAdapter(NotificationsUserModelAdapter());
  return await Hive.openBox<NotificationsUserModel>('notifications');
});


class NotificationsProvider extends StateNotifier<AsyncValue<List<NotificationsUserModel>?>> {
  final Ref ref;
  List<NotificationsUserModel>? notifications;

  NotificationsProvider(this.ref) : super(const AsyncValue.loading()) {
    _loadNotificationsLocally();
  }

   Future<void> _loadNotificationsLocally() async {
    state = const AsyncValue.loading();
     try {
      final box = await ref.read(notificationsBoxProvider.future);
      notifications = box.values.toList();
      state = AsyncValue.data(notifications);
      } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      }
  }

  Future<void> addNotificationsLocally(NotificationsUserModel notification) async {
    try {
      final box = await ref.read(notificationsBoxProvider.future);
      await box.add(notification);
      notifications = box.values.toList();
      state = AsyncValue.data(notifications);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}


final notificationsProvider =
    StateNotifierProvider<NotificationsProvider, AsyncValue<List<NotificationsUserModel>?>>(
  (ref) => NotificationsProvider(ref),
);