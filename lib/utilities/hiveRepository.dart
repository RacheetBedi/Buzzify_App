import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/group_models/hive.dart';
import 'package:flutter_app/models/group_models/hive_default_settings_model.dart';
import 'package:flutter_app/models/group_models/nectar_points_default_settings_model.dart';
import 'package:flutter_app/models/user_models/app_user.dart';
import 'package:flutter_app/models/user_models/nectar_points_user_model.dart';
import 'package:flutter_app/models/user_models/notifications_user_model.dart';
import 'package:flutter_app/models/user_models/task_model.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/hive_service_provider.dart';
import 'package:flutter_app/providers/hive_service_provider.dart';
import 'package:flutter_app/utilities/userRepository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class HiveRepository{
  final WidgetRef ref;
  String? uid = 'uninitialized';
  bool hiveMade = false;
  //This is the uid of the hive, automatically assigned by Firestore.

  HiveRepository(this.ref, [this.uid]){
    if(uid == 'uninitialized'){
      hiveMade = false;
    }
  }

  Hive? get currentHive{
    final hiveState = ref.read(hiveServiceProvider);
    uid = hiveState.asData?.value?.hive_uid;
    return hiveState.asData?.value;
  }

  Future<DocumentReference<Map<String, dynamic>>> get hiveDocument async{
    return _firestore.collection('groups').doc(uid);
  }

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<Hive?> initializeCurrentHive() async{
    try{
      final currentUser = UserRepository(ref).currentAppUser;
      final hiveDocRef;
      if(hiveMade){
        hiveDocRef = await hiveDocument;
      }
      else{
        return null;
      }
      if(hiveDocRef == null) return null;
      Get.snackbar('Initializing the Hive', 'Please help me');

      final hiveDoc = await hiveDocRef.get(); //Fix the reading of the data (make it proper, distinguishing between a snippet and all of the data)
      //In this case, we want to only read a snippet
      if(!hiveDoc.exists) return null;

      final mainHiveData = hiveDoc.data();

      final defaultSettings = HiveDefaultSettingsModel(
        additionEnabled: mainHiveData?['default_settings']?['additionEnabled'] ?? false, 
        appreciationEnabled: mainHiveData?['default_settings']?['appreciationEnabled'] ?? false, 
        logEnabled: mainHiveData?['default_settings']?['logEnabled'] ?? false, 
        taskRemovalEnabled: mainHiveData?['default_settings']?['taskRemovalEnabled'] ?? false, 
        summaryEnabled: mainHiveData?['default_settings']?['summaryEnabled'] ?? false, 
        tradingEnabled: mainHiveData?['default_settings']?['tradingEnabled'] ?? false); //Fix the firestore references.

      // final hiveUserDataDocRef = _firestore.collection('groups').doc(uid).collection('group_users').doc('user_data');
      // final hiveUserDataDoc = await hiveUserDataDocRef.get();
      // final hiveUserRoleData = hiveUserDataDoc.data();

      String curUserRole = '';
      final userHives = currentUser?.possessions?.hivesJoined;

      for(int i = 0; i<userHives!.length; i++){
        if(userHives[i].hive_uid == uid){
          curUserRole = userHives[i].user_role;
        }
      }
      

      final hive = Hive(
        hive_uid: hiveDoc.id,
        hive_name: mainHiveData?['hive_name'] ?? '',
        hive_description: mainHiveData?['hive_description'] ?? '',
        hive_subject: mainHiveData?['hive_subject'] ?? '',
        hive_code: mainHiveData?['hive_code'] ?? '',
        points_description: mainHiveData?['points_description'] ?? '',
        icon_description: mainHiveData?['icon_description'] ?? '',
        default_settings: defaultSettings,
        teacher_led: mainHiveData?['teacher_led'] ?? false,
        theme_color: mainHiveData?['theme_color'] ?? 'blue',
        hiveImage: mainHiveData?['hiveImage'],
        hive_creator: mainHiveData['hiveCreatorUID'] ?? '',
        user_role: curUserRole,
      );



    } catch (e){
      Get.snackbar("Error", "Failed to initialize in user repository: $e");
      return null;
    }
  }


  Future<void> createHiveDoc(Hive hive) async {
    try{
      final curUser = UserRepository(ref).currentAppUser;
      if(curUser == null) throw Exception("No current user found");

      curUser.possessions?.hivesJoined?.add(hive);

      final mainHiveRef = _firestore.collection('groups').doc(); 
      
      //If the hive hasn't been made yet, that means that
        //the hive uid is null; so to prevent a firestore error, we use this dummy uid which will
        //certainly fail to produce a docRef and thus proceed to the creation step below.
      final mainHiveDoc = await mainHiveRef.get();

      await mainHiveRef.set({
          'hive_name': hive.hive_name ?? '',
          'hive_description': hive.hive_description ?? '',
          'hive_points_description': hive.points_description ?? '',
          'nectar_snippet': hive.nectar_snippet?.map((item) => item.toMap()).toList() ?? [],
          'default_settings': hive.default_settings?.toMap() ?? {},
          'hive_icons_description': hive.icon_description ?? '',
          //'hive_join_code': hive.hive_code, do this when you code the join code auto generation
          'hive_tasks_snippet': hive.tasks_snippet?.map((item) => item.toMap()).toList() ?? [],
          'teacher_led': hive.teacher_led ?? true,
          'theme_color': hive.theme_color.hashCode.toString() ?? 'hashCodePlaceholder',
          'hiveImage': hive.hiveImage ?? 'PhotoURLPlaceholder',
      });

      //Fix the default settings, nectar snippet, recent updates, assigned tasks, and completed tasks based on the following criteria:
      // 1. Firestore reads/writes minimization
      // 2. Object separation (each element of the object is a separate Firestore field)
      // 3. Ease of access (initialize snippets and the main Hive initially, but do nectar points, assigned tasks, completed tasks, and recent updates on demand, with a load more button for the snippets)

      hive.hive_uid = mainHiveRef.id;
      hiveMade = true;

      final recentUpdatesDocRef = _firestore.collection('groups').doc(mainHiveRef.id).collection('Recent Updates').doc('set_1');
      //Change set_1 to set_# based on the number of days elapsed since the creation of the hive, divided by 3.
      //We will automatically start deleting sets of recent updates when reaching around 50 sets (150 days).

      final hiveUsersDocRef = _firestore.collection('groups').doc(mainHiveRef.id).collection('group_users').doc('user_data');
      final assignedTasksDocRef = _firestore.collection('groups').doc(mainHiveRef.id).collection('tasks').doc('assigned_task_properties').collection('Assigned Tasks List').doc('tasks_set_1');
      final completedTasksDocRef = _firestore.collection('groups').doc(mainHiveRef.id).collection('tasks').doc('completed_task_properties').collection('Completed Tasks List').doc('completedTasks_set_1');

      await recentUpdatesDocRef.set({
        'recent_updates': hive.recent_updates ?? [],
      });

      await hiveUsersDocRef.set({
        'hive_users': hive.hive_users ?? [],
      });

      await assignedTasksDocRef.set({
        'assigned_tasks': hive.assigned_tasks ?? [],
      });

      await completedTasksDocRef.set({
        'completed_tasks': hive.completed_tasks ?? [],
      });

      UserRepository(ref).updateHivesJoinedData(latestHivesJoined: [hive]);
    } catch(err, st){
      Get.snackbar('Error', 'Failed to create Hive document: $err');
    }
  }

  Future<void> addAssignedTask(TaskModel task) async {
    final hive = currentHive;
    if(hive == null) return;

    final assignedTasksDocRef = _firestore.collection('groups').doc(hive.hive_uid).collection('tasks').doc('assigned_task_properties').collection('Assigned Tasks List').doc('tasks_set_1');
    final assignedTasksDoc = await assignedTasksDocRef.get();

    if(assignedTasksDoc.exists){
      await assignedTasksDocRef.update({
        'assigned_tasks': FieldValue.arrayUnion([task.toMap()]), //Name it something else...
      });
    }
  }

  Future<void> updateHiveDocData({
    required Hive hive,
    String? hive_name,
    String? hive_description,
    String? hive_subject,
    String? hive_code,
    String? points_description,
    String? icon_description,
    HiveDefaultSettingsModel? default_settings,
    bool? teacher_led,
    bool? ai_summary,
    Color? theme_color,
    String? hiveImage,
    //Snippets can't be changed, they are set directly through firestore. When a task or something
    //else hive related is added, the hive document is updated, and the appreciation/task snippets are automatically triggered to update as well.
    List<NotificationsUserModel>? recent_updates,
    NectarPointsDefaultSettingsModel? nectar_default_settings,
    NectarPointsUserModel? nectar_points,
    List<AppUser>? hive_users,
    List<TaskModel>? assigned_tasks,
    List<TaskModel>? completed_tasks,
    }) async {

      final hive = currentHive;

      final curUser = UserRepository(ref).currentAppUser;
      if(curUser == null) return;

      bool mainHiveElementsChanged = false;

      final mainHiveRef = _firestore.collection('groups').doc(hive?.hive_uid); 
      final mainDoc = mainHiveRef.get();

      //Figure out a way so that recent updates are uploaded every day, into sets of 3 days' worth.
      final recentUpdatesDocRef = _firestore.collection('groups').doc(hive?.hive_uid).collection('Recent Updates').doc('set_1'); 
      //The set will be dependent on the number of days elapsed since the creation of the hive, divided by 3. We will automatically start deleting sets of recent updates when reaching around 50 sets (150 days).
      final recentUpdatesDoc = recentUpdatesDocRef.get();

      final hiveUsersDocRef = _firestore.collection('groups').doc(hive?.hive_uid).collection('group_users').doc('user_data');
      final hiveUsersDoc = hiveUsersDocRef.get();

      final assignedTasksDocRef = _firestore.collection('groups').doc(hive?.hive_uid).collection('tasks').doc('assigned_task_properties').collection('Assigned Tasks List').doc('tasks_set_1');
      final assignedTasksDoc = assignedTasksDocRef.get();
      final completedTasksDocRef = _firestore.collection('groups').doc(hive?.hive_uid).collection('tasks').doc('completed_task_properties').collection('Completed Tasks List').doc('completedTasks_set_1');

      final nectarPointsSettingsDocRef = _firestore.collection('groups').doc(hive?.hive_uid).collection('appreciation_points').doc('appreciation_properties');
      final nectarPointsPeopleDocRef = _firestore.collection('groups').doc(hive?.hive_uid).collection('appreciation_points').doc('appreciation_people_status');
      final nectarPointsSettingsDoc = nectarPointsSettingsDocRef.get();
      final nectarPointsPeopleDoc = nectarPointsPeopleDocRef.get();

      if(hive_name != null){
        hive?.hive_name = hive_name;
        mainHiveElementsChanged = true;
      }

      if(hive_description != null){
        hive?.hive_description = hive_description;
        mainHiveElementsChanged = true;
      }

      if(hive_subject != null){
        hive?.hive_subject = hive_subject;
        mainHiveElementsChanged = true;
      }

      if(hive_code != null){
        hive?.hive_code = hive_code;
        mainHiveElementsChanged = true;
      }

      if(points_description != null){
        hive?.points_description = points_description;
        mainHiveElementsChanged = true;
      }

      if(icon_description != null){
        hive?.icon_description = icon_description;
        mainHiveElementsChanged = true;
      }

      if(default_settings != null){
        hive?.default_settings = default_settings;
        mainHiveElementsChanged = true;
      }

      if(teacher_led != null){
        hive?.teacher_led = teacher_led;
        mainHiveElementsChanged = true;
      }

      if(theme_color != null){
        hive?.theme_color = theme_color;
        mainHiveElementsChanged = true;
      }

      if(hiveImage != null){
        hive?.hiveImage = hiveImage;
        mainHiveElementsChanged = true;
      }

      if(mainDoc !=null && mainHiveElementsChanged){
        final updateData = <String, dynamic>{
          if(hive_name != null) 'hive_name': hive_name,
          if(hive_description != null) 'hive_description': hive_description,
          if(hive_subject != null) 'hive_subject': hive_subject,
          if(hive_code != null) 'hive_code': hive_code,
          if(points_description != null) 'points_description': points_description,
          if(icon_description != null) 'icon_description': icon_description,
          if(default_settings?.additionEnabled != null) 'default_settings.addition_enabled' : default_settings?.additionEnabled,
          if (default_settings?.appreciationEnabled != null) 'default_settings.appreciation_enabled' : default_settings?.additionEnabled,
          if (default_settings?.logEnabled != null) 'default_settings.log_enabled' : default_settings?.logEnabled,
          if (default_settings?.taskRemovalEnabled != null) 'default_settings.removal_enabled' : default_settings?.taskRemovalEnabled,
          if (default_settings?.summaryEnabled != null) 'default_settings.summary_enabled' : default_settings?.summaryEnabled,
          if (default_settings?.tradingEnabled != null) 'default_settings.trading_enabled' : default_settings?.tradingEnabled,
          if(teacher_led != null) 'teacher_led': teacher_led,
          if(ai_summary != null) 'ai_summary': ai_summary,
          if(theme_color != null) 'theme_color': theme_color,
          if(hiveImage != null) 'hiveImage': hiveImage,
        };
        await mainHiveRef.update(updateData);
      }


      if(recentUpdatesDoc != null && recent_updates != null){
        final List<Map<String, dynamic>> recentUpdatesMap = recent_updates.map((update) => update.toMap()).toList();
        await recentUpdatesDocRef.update({
          'recent_updates': FieldValue.arrayUnion(recentUpdatesMap),
        });
      }

      if(hiveUsersDoc != null && hive_users != null){
        await hiveUsersDocRef.update({
          'hive_users': hive_users,
        });
      }

      if(assignedTasksDoc != null && assigned_tasks != null){
        await assignedTasksDocRef.update({
          'assigned_tasks': assigned_tasks,
        });
      }

      if(completedTasksDocRef != null && completed_tasks != null){
        await completedTasksDocRef.update({
          'completed_tasks': completed_tasks,
        });
      }

      if(nectarPointsSettingsDocRef != null && nectar_default_settings != null){
        await nectarPointsSettingsDocRef.update({
          if(nectar_default_settings.icons_tradeable != null) 'icons_tradeable' : nectar_default_settings.icons_tradeable,
          if(nectar_default_settings.leaderboard_enabled != null) 'leaderboard_enabled' : nectar_default_settings.leaderboard_enabled,
          if(nectar_default_settings.points_tradeable != null) 'points_tradeable' : nectar_default_settings.points_tradeable,
        });
      }

      if(nectarPointsPeopleDoc != null && nectar_points != null){
        await nectarPointsPeopleDocRef.update({
          if(nectar_points.achievementsEarned != null ) '${curUser.uid}.achievements_earned' : 'placeholder', //Convert the enums into one map and replace the placeholder with that map
          if(nectar_points.mostHelped != null) '${curUser.uid}.mostHelpedMember' : nectar_points.mostHelped?.uid,
          if(nectar_points.numIconsEarned != null) '${curUser.uid}.numAchievementsEarned' : nectar_points.numIconsEarned, //Each achievement corresponds to an icon, so the numbers should be the same for both
          if(nectar_points.numPointsEarned != null) '${curUser.uid}.numPointsEarned' : nectar_points.numPointsEarned,
          if(nectar_points.popularHive != null) '${curUser.uid}.mostPopularHive' : nectar_points.popularHive?.hive_uid,
        });
      }


      //These are placeholder update statements; each of these will require a 
      //separate method to update, which needs to be coded later.
  }

  // Future<bool> hasCompletedHiveSetup() async {
  //   final hive = hiveDocuments;
  //   if(hive == null) return false;
  //   final doc = await _firestore.collection('groups').doc(uid).get();
  //   return doc.exists && (doc.data()?['hasCompletedHiveSetup'] == true);
  // }

  //Implement later when hasCompletedSetup bugs have been resolved.
}

/* Recent updates buffer:
Recommended architecture (best for many users):
Client: buffer locally and upload a single per-user-per-day doc at groups/{hive}/user_daily_updates/{YYYY-MM-DD}_{uid}.
Server aggregator (Cloud Function / Cloud Run scheduled job): nightly/periodic job reads all user_daily_updates for a hive/day, aggregates into the hive-level document(s) (or pre-computed summaries), then deletes or archives the per-user docs.
Lifecycle: delete or move per-user docs after aggregation, or use Firestore TTL to auto-delete older docs.
Why this scales: avoids hot-document contention (clients don't all write the same doc), lets you batch/merge writes server-side with BulkWriter, and controls retention to bound storage growth.
If you must avoid server-side jobs: clients can upload to per-user docs and the UI can merge at read-time — still avoids contention but increases read costs and read-time complexity.
If payloads are large: store details in Cloud Storage and keep a small Firestore metadata doc referencing the file.
Operational tips:
Use Firestore TTL to auto-delete old user_daily_updates docs.
Use BulkWriter or batched writes in your aggregator for throughput.
Secure writes so users can only write their own {date}_{uid} docs.
Keep per-doc size under 1MB; compress or chunk if needed.
Monitor costs and set retention (e.g., keep raw per-user docs 7 days after aggregation).
*/