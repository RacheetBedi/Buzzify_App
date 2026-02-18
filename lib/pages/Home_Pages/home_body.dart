import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/enums/navigation_enum.dart';
import 'package:flutter_app/models/user_models/app_user.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/utilities/userRepository.dart';
import 'package:flutter_app/widgets/google_classroom_widget.dart';
import 'package:flutter_app/widgets/nectar_center_recent_comments_widget.dart';
import 'package:flutter_app/widgets/normal_task_widget.dart';
import 'package:flutter_app/widgets/recent_updates_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

class HomeBody extends ConsumerStatefulWidget {
  final Function(NavigationPage) onNavigate;
  const HomeBody({super.key, required this.onNavigate});

  @override
  ConsumerState<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends ConsumerState<HomeBody> {
  bool _isUserInitialized = false;

  Future<bool> checkLoggedIn() async {
    final authState = ref.read(authProvider);
    final user = authState.asData?.value;
    return user != null && (user.email?.isNotEmpty ?? false);
  }

  Future<AppUser?> initializeUser() async {
    try {
      if (await checkLoggedIn() == true) {
        Get.snackbar("Note", "Initializing User Data...");
        final user = await UserRepository(ref).initializeAppUserObject();
        if (user == null) {
          Get.snackbar("Error", "User doc either absent or timeout reached.");
          return null;
        }
        setState(() {
          _isUserInitialized = true;
        });
        return user;
      }
    } catch (e) {
      Get.snackbar("Error", "Error initializing user: $e");
      return null;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   _isUserInitialized = true;
    //   setState(() {});
    //   initializeUser();
    // });
    initializeUser();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        padding: const EdgeInsets.only(top: 10.0),
        shrinkWrap: true,
        children: [
          const NormalTaskWidget(
            title: "My Tasks",
            tasks: [
              {'name': 'Complete Math Homework', 'description': 'Finish chapter 5 exercises'},
              {'name': 'Read Science Chapter', 'description': 'Read pages 45-67'},
              {'name': 'Write Essay', 'description': '500-word essay on climate change'},
              {'name': 'Study for Test', 'description': 'Review biology notes'},
            ],
          ),
          const SizedBox(height: 15),
          const GoogleClassroomWidget(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => widget.onNavigate(NavigationPage.hives),
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100000000))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.groups, size: 30, color: Color(0xFFFF0000)), SizedBox(width: 10), Text("My Hives", style: TextStyle(fontFamily: 'Jomhuria', fontSize: 40, color: Color(0xFFFF0000)))]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => widget.onNavigate(NavigationPage.tracking),
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100000000))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.track_changes, size: 30, color: Color(0xFFFF7F6E)), SizedBox(width: 10), Text("Assignment Progress", style: TextStyle(fontFamily: 'Jomhuria', fontSize: 40, color: Color(0xFFFF7F6E)))]),
          ),
          const SizedBox(height: 20),
          const NectarCenterCommentsWidget(),
          const SizedBox(height: 20),
          const RecentUpdatesWidget(),
        ],
      ),
    );
  }
}