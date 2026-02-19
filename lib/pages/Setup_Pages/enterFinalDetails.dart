import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/enums/navigation_enum.dart';
import 'package:flutter_app/pages/Setup_Pages/final_steps_question.dart';
import 'package:flutter_app/pages/Setup_Pages/verifyPhone.dart';
import 'package:flutter_app/pages/Setup_Pages/login_page.dart';
import 'package:flutter_app/pages/Home_Pages/home_body.dart';
import 'package:flutter_app/pages/Main_Settings_Pages/settings.dart';
import 'package:flutter_app/pages/Home_Pages/main_page.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/routing/wrapper.dart';
import 'package:flutter_app/utilities/userRepository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/sockets/src/sockets_io.dart';
import 'package:get/get_core/src/get_main.dart';

class EnterfinalDetails extends ConsumerStatefulWidget {
  const EnterfinalDetails({super.key});

  @override
  ConsumerState<EnterfinalDetails> createState() => _EnterfinalDetailsState();
}

class _EnterfinalDetailsState extends ConsumerState<EnterfinalDetails> {

  TextEditingController description = TextEditingController();

  Future<bool> saveDescription() async {
    String descrip = description.text.trim();
    final currentUser = UserRepository(ref).currentAppUser;

    if (currentUser != null) {
      await UserRepository(ref).updateMainDocumentData(description: descrip);
      return true;
    }
    else{
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Hive Background.png"),
            repeat: ImageRepeat.repeat,
            fit: BoxFit.none,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    iconSize: 40,
                    onPressed: () => Get.back(),
                  ),
                  ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  children: [
                    const SizedBox(height: 5,),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(0, 255, 255, 255),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/images/Oval Logo.png",
                          height: 125,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Enter Your Description',
                      style: TextStyle(
                        fontSize: 50, 
                        fontFamily: 'Jomhuria'
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Please enter a description for your account. This will help others understand more about you, and it is visible to everyone.\nNOTE: Do not include any personal or confidential information which you would not like to disclose to the general public.',
                      style: TextStyle(
                        fontSize: 20.0, 
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0)
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: description,
                      expands: true,
                      minLines: null,
                      maxLines: null,
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        hintText: 'Enter description here...',
                        constraints: BoxConstraints(
                          maxWidth: 350,
                          minWidth: 50,
                          minHeight: 50,
                          maxHeight: 200,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15,),
                    ElevatedButton(
                      onPressed: () async{
                        bool result = await saveDescription();
                        if(result){
                          Get.to(() => MainPage(initialPage: NavigationPage.settings));
                        } else{
                          Get.snackbar("Error", "Failed to save description. Please try again.");
                        }
                      },
                      child: const Text("Save and Configure More Settings")
                    ),
                    const SizedBox(height: 15,),
                    ElevatedButton(
                      onPressed: () async{
                        bool result = await saveDescription();
                        if(result){
                          Get.to(() => MainPage(initialPage: NavigationPage.home));
                        } else{
                          Get.snackbar("Error", "Failed to save description. Please try again.");
                        }
                      },
                      child: const Text('Done with Setup'),
                    ),
                  ]
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}