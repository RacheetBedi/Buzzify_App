import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/enums/navigation_enum.dart';
import 'package:flutter_app/models/user_models/app_user.dart';
import 'package:flutter_app/pages/Forgot_Pages/forgot.dart';
import 'package:flutter_app/pages/Setup_Pages/enterFinalDetails.dart';
import 'package:flutter_app/pages/Setup_Pages/login_page.dart';
import 'package:flutter_app/pages/Setup_Pages/signupStudent.dart';
import 'package:flutter_app/pages/Home_Pages/main_page.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/routing/wrapper.dart';
import 'package:flutter_app/utilities/userRepository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

//enum Origin{forgot, setup} (use this if routing stops working)

class VerifyPhone extends ConsumerStatefulWidget {
  //final Origin from;
  final String number;
  VerifyPhone(this.number, {super.key});

  @override
  ConsumerState<VerifyPhone> createState() => _VerifyPhoneState(number);
}

class _VerifyPhoneState extends ConsumerState<VerifyPhone> {

  int _countdown = 60;
  Timer? _timer;
  bool _isResendEnabled = false;
  final String number;
  ConfirmationResult? _confirmationResult;
  bool _hasSent = false;
  bool resendCode = true;

  TextEditingController phoneCode = TextEditingController();
  bool isCodeEnabled = false;

  _VerifyPhoneState(this.number);

  String? _verificationID;
  

  @override
  void initState() {
    _startTimer();
    super.initState();
  }

  void _startTimer()
  {
    setState((){
      _isResendEnabled = false;
      _countdown = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState((){
        if(_countdown > 0)
        {
          _countdown--;
        }
        else
        {
          _timer?.cancel();
          _isResendEnabled = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> signInWithPhone(PhoneAuthCredential phoneAuthCredential) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      if(userCredential.user != null){
        await loginSuccessPopup();
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "ERROR",
        "Phone number sign-in error: ${e.message}",
        duration: const Duration(seconds: 10),
      );
    }
  }

  linkSuccessPopup() async {
    final authNotifier = ref.read(authProvider.notifier);
    final result = await showDialog<bool>(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("PHONE NUMBER ADDED"),
        content: const Text("Do you wish to continue in the setup process?"),
        actions: [
          ElevatedButton(
            onPressed: (){
              Navigator.pop(context, true);
            },
            child: const Text("YES"),
          ),
          const SizedBox(height: 10,),
          ElevatedButton(
            onPressed: (){
              Navigator.pop(context, false);
            }, 
            child: const Text("NO"),
          ),
        ]
      ),
    );

    if(result == true){
      Get.to(() => const EnterfinalDetails());
    }
    else{
      Get.to(() => MainPage(initialPage: NavigationPage.home));
    }
  }

  loginSuccessPopup() async {
    final authNotifier = ref.read(authProvider.notifier);
    final result = await showDialog<bool>(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("SUCCESSFULLY SIGNED IN!"),
        content: const Text("You have signed in with your phone number. Please click the button below to proceed."),
        actions: [
          ElevatedButton(
            onPressed: (){
              Navigator.pop(context, true);
            },
            child: const Text("Go to Home"),
          ),
          const SizedBox(height: 10,),
        ]
      ),
    );

    if(result == true){
      Get.to(() => MainPage(initialPage: NavigationPage.home));
    }
  }

  Future<void> verifySMSCode(String smsCode) async{
    if(_verificationID == null){
      Get.snackbar(
        "ERROR",
        "No verification ID. Please request a new code.",
        duration: const Duration(seconds: 10),
      );
      return;
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationID!,
      smsCode: smsCode,
    );

    final user = FirebaseAuth.instance.currentUser;

    if(user == null){
      signInWithPhone(credential);
    }
    else{
      try{
        final authState = ref.read(authProvider);
        await user.linkWithCredential(credential);
        await UserRepository(ref).updateMainDocumentData(phoneNumber: int.parse(widget.number));
        await linkSuccessPopup();
        Get.snackbar('Success', 'Phone number added successfully.');
      } on FirebaseAuthException catch (e) {
        Get.snackbar(
          "ERROR",
          "SMS Code Verification Error: ${e.message}",
          duration: const Duration(seconds: 10),
        );  
      }
    }
  }

  Future<void> linkPhoneNumber(String phoneNumber) async{
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential credential) async { //For android phones only (on the web emulator a code must manually be entered)
        if (user == null) throw Exception ('No user is currently signed in.');
        try{
          await user.linkWithCredential(credential);
          Get.offAll(() => MainPage(initialPage: NavigationPage.home,));
        } on FirebaseAuthException catch (e) {
          Get.snackbar(
            "ERROR",
            "Phone number linking error: ${e.code} and ${e.message}",
            duration: const Duration(seconds: 10),
          );  
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        Get.snackbar(
          "ERROR",
          "Phone number verification failed: ${e.code} and ${e.message}",
          duration: const Duration(seconds: 10),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        Get.snackbar('Message Sent', 
        'A message has been sent to your provided number. It may take up to 5 minutes to arrive.');
         setState(() {
           _verificationID = verificationId;
         });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        Get.snackbar('Timeout', 'Automatic code retrieval timed out. Please enter the code manually');
        setState(() {
           _verificationID = verificationId;
         });
      },
    );
  }

  timeandSend() {
    linkPhoneNumber(widget.number);
    _startTimer();
  }

  /*sendverifyMessage() async{
    //FIX FOR MOBILE( USE KISWEB!!!)!!!
    final appUser = UserRepository(ref).currentAppUser;

    //Going from forgot password flow
    if(appUser == null){

    }

    _confirmationResult = await FirebaseAuth.instance.signInWithPhoneNumber(number);
    
    return Get.snackbar('Message Sent', 'If you possess an account, a message has been sent to your provided number. It may take up to 5 minutes.');
  }
  checkCode(String code) async{
    try{
    final userCredential = await(_confirmationResult)?.confirm(code);
    if(userCredential?.user != null){
      AppUser appUser = AppUser.fromFirebaseUser(userCredential!.user! , hasCompletedSetup: true);
      final authState = ref.read(authProvider);
      // Add a set appUser to the current user for riverpod method in authProvider.
      Get.offAll(() => const Home());
    }
    else{
      Get.snackbar(
        "ERROR",
        "The code you entered is invalid. Please try again.",
        duration: const Duration(seconds: 10),
      );
    }
    } catch(e){
      Get.snackbar(
        "ERROR",
        "User code verification error: ${e.toString()}",
        duration: const Duration(seconds: 10),
      );
    }
  }
  checkConfirmation(String code) async{
    //FIX FOR MOBILE!!!
    if(_confirmationResult == null){
      Get.snackbar(
        "ATTENTION",
        "You failed to validate the request. Please try again.",
        duration: const Duration(seconds: 10),
      );
      return;
    }
    else{
      await checkCode(code);
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final appUser = ref.watch(authProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(!_hasSent){
        Get.snackbar('Phone number provided:', widget.number);
        linkPhoneNumber(widget.number);
        _hasSent = true;
      }
    });
  
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(height: 15,),
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
                    const SizedBox(height: 15),
                    const Text(
                      'Verify Your Phone',
                      style: TextStyle(
                        fontSize: 50, 
                        fontFamily: 'Jomhuria'
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'You have been sent a verification message. Please enter your received code.\nNOTE: Standard SMS rates apply.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.0, 
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0)
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: phoneCode,
                      decoration: const InputDecoration(
                        hintText: 'Enter verification code',
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: (){
                        verifySMSCode(phoneCode.text.trim());
                      },//checkConfirmation(phoneCode.text.trim()),
                      child: const Text("Check Code"),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Didn\'t get the message?', 
                      style: TextStyle(
                        fontSize: 20.0, 
                        fontFamily: 'Inter', 
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 73, 73, 73)
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _isResendEnabled ? timeandSend : null,
                      child: Text(_isResendEnabled ? "Resend Message" : '$_countdown s'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}