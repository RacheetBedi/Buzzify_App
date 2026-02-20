import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/pages/Setup_Pages/verifyPhone.dart';
import 'package:flutter_app/pages/Setup_Pages/login_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class Forgot extends ConsumerStatefulWidget {
  const Forgot({super.key});

  @override
  ConsumerState<Forgot> createState() => _ForgotState();
}

class _ForgotState extends ConsumerState<Forgot> {

  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();

  String _code = '+1';

  passwordReset()async{
    if(email.text.isEmpty && phone.text.isEmpty){
      Get.snackbar(
        "Error",
        "Please enter either your email or phone number to reset your password.",
      );
      return;
    }
    if(email.text.isNotEmpty && phone.text.isNotEmpty){
      Get.snackbar(
        "Error",
        "Please enter EITHER your email or phone number, not both.",
      );
      return;
    }

    if(email.text.isNotEmpty){
      if((!email.text.contains("@gmail.com") && !email.text.contains("@icloud.com") && !email.text.contains("@outlook.com") && !email.text.contains("@yahoo.com")) ||
        (email.text == "@gmail.com" || email.text == "@icloud.com" || email.text == "@outlook.com" || email.text == "@yahoo.com")){
        Get.snackbar(
          "ATTENTION:",
          "Please ensure your email has the correct formatting.\nNOTE: We do not accept uncommon email domains. If your email fails, we recommend you send the reset request using your phone number instead.",
        );
        return;
      }
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim(),);

      dynamic result;
      if(mounted){
      result = await showDialog<bool>(
        context: context, 
        builder: (context) => AlertDialog(
          title: const Text("If your email is registered, a password reset link has been sent. Please follow the instructions in the email to reset your password."),
          content: const Text("NOTE: Check your spam/junk folder if you do not see the email in your inbox."),
          actions: [
            ElevatedButton(
              onPressed: (){
                Navigator.pop(context, true);
              }, 
              child: const Text("OK"),
            ),
          ]
        ),
      );
      }

      if (result == true){
        Get.to(() => const LoginPage());
      }
    }

    if(phone.text.isNotEmpty){
      if(phone.text.length > 10){
        Get.snackbar(
          'ATTENTION:',
          'Please ensure your phone number has the correct formatting. Do NOT include the country code.\nNOTE: We only accept U.S. phone numbers. If you have an international number, please enter an email instead.',
        );
      }
      Get.to(() => VerifyPhone('$_code${phone.text}'));
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
                    onPressed: () => Get.to(() => const LoginPage()),
                  ),
                  ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20.0),
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
                      'Forgot Your Password?',
                      style: TextStyle(
                        fontSize: 50, 
                        fontFamily: 'Jomhuria'
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: email,
                      decoration: const InputDecoration(hintText: 'Enter email to reset password'),
                    ),
                    const SizedBox(height: 15,),
                    const Text(
                      "--- OR ----",
                      textHeightBehavior: TextHeightBehavior(
                        applyHeightToFirstAscent: true,
                        applyHeightToLastDescent: true,
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Jomhuria',
                        fontSize: 30,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale: 1,
                          child: DropdownMenu<CountryCodeLabel>(
                            width: MediaQuery.of(context).size.width * 0.25,
                            initialSelection: CountryCodeLabel.america,
                            onSelected: (CountryCodeLabel? countryCode) {
                              setState(() {
                                _code = countryCode?.label ?? "+1";
                              });
                            },
                            dropdownMenuEntries: CountryCodeLabel.entries
                          ),
                        ),
                        const SizedBox(width: 10,),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            controller: phone,
                            decoration: const InputDecoration(hintText: 'Sign in with phone number'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    const Text(
                      'NOTE: You will receive a verification message to sign in directly. Standard SMS rates apply.',
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: (()=> passwordReset()),
                      child: const Text("Send link")
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

typedef CountryCodeEntry = DropdownMenuEntry<CountryCodeLabel>;

enum CountryCodeLabel{
  america('+1'),
  unitedKingdom('+44'),
  australia('+61'),
  germany('+49'),
  france('+33'),
  italy('+39'),
  netherlands('+31');

  const CountryCodeLabel(this.label);
  final String label;

  static final List<DropdownMenuEntry<CountryCodeLabel>> entries =
      CountryCodeLabel.values.map((countryCode) {
    return DropdownMenuEntry<CountryCodeLabel>(
      value: countryCode,
      label: countryCode.label,
    );
  }).toList();
}