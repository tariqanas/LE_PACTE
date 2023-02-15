import 'package:eachday/services/emailLogin.dart';
import 'package:eachday/signInScreen.dart';
import 'package:eachday/utils/eachdayutils.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/components/text_field/gf_text_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key, required this.isUserSignIn}) : super(key: key);

  final bool isUserSignIn;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmationController =
      TextEditingController();
  TextEditingController userNameController = TextEditingController();

  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  bool circular = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black,
                child: ListView(children: [
                  SizedBox(
                    height: 200,
                    child:  Image.asset("assets/splash/each_day_splash.png"),
                  ),
                  GFTextField(
                    autocorrect: false,
                    autofocus: false,
                    maxLength: 50,
                    maxLines: 1,
                    controller: emailController,
                    keyboardAppearance: Brightness.dark,
                    decoration:  InputDecoration(
                        labelText: AppLocalizations.of(context).giveMeAnEmail,
                        prefixIcon: const Icon(Icons.email),
                        labelStyle: const TextStyle(color: Colors.white),
                        errorMaxLines: 1,
                        filled: true,
                        fillColor: const Color.fromARGB(255, 117, 15, 15)),
                    style: const TextStyle(color: Colors.white),
                    expands: false,
                    showCursor: true,
                  ),
                  GFTextField(
                    keyboardAppearance: Brightness.light,
                    obscureText: true,
                    autofocus: false,
                    expands: false,
                    maxLength: 50,
                    maxLines: 1,
                    showCursor: true,
                    controller: passwordController,
                    decoration:  InputDecoration(
                        labelText: AppLocalizations.of(context).giveMeAPassword,
                        prefixIcon: const Icon(Icons.lock),
                        labelStyle: const TextStyle(color: Colors.white),
                        errorMaxLines: 1,
                        filled: true,
                        fillColor: const Color.fromARGB(255, 117, 15, 15)),
                    fieldinitialValue: AppLocalizations.of(context).fillYourPactePass,
                    style: const TextStyle(color: Colors.white),
                    color: Colors.white,
                  ),
                  if (!widget.isUserSignIn)
                    GFTextField(
                      keyboardAppearance: Brightness.light,
                      obscureText: true,
                      autofocus: false,
                      expands: false,
                      maxLength: 50,
                      maxLines: 1,
                      showCursor: true,
                      controller: passwordConfirmationController,
                      decoration:  InputDecoration(
                          labelText: AppLocalizations.of(context).confirmYourPassword,
                          prefixIcon: const Icon(Icons.lock),
                          labelStyle: const TextStyle(color: Colors.white),
                          errorMaxLines: 1,
                          filled: true,
                          fillColor: const Color.fromARGB(255, 117, 15, 15)),
                      fieldinitialValue: AppLocalizations.of(context).fillYourPactePass,
                      style: const TextStyle(color: Colors.white),
                      color: Colors.white,
                    ),
                  if (!widget.isUserSignIn)
                    GFTextField(
                      keyboardAppearance: Brightness.light,
                      autocorrect: true,
                      autofocus: false,
                      maxLength: 10,
                      maxLines: 1,
                      expands: false,
                      showCursor: true,
                      controller: userNameController,
                      decoration:  InputDecoration(
                          labelText: AppLocalizations.of(context).yourName,
                          prefixIcon: const Icon(Icons.spoke),
                          labelStyle: const TextStyle(color: Colors.white),
                          errorMaxLines: 1,
                          filled: true,
                          fillColor: const Color.fromARGB(255, 117, 15, 15)),
                      style: const TextStyle(color: Colors.white),
                      fieldinitialValue: AppLocalizations.of(context).disciple ,
                      color: Colors.white,
                    ),
                  if (!widget.isUserSignIn)
                    buttonItem(
                        "assets/icon/demon.svg",
                        passwordController.text ==
                                passwordConfirmationController.text
                            ? AppLocalizations.of(context).createNewAccount
                            : AppLocalizations.of(context).differentPassword,
                        25, () {
                      final emailSignIn = EmailSignIn();
                      if (passwordConfirmationController.text !=
                          passwordController.text) {
                        SnackBar snackBar = EachDaysUtils.ShowSnackBar(
                           AppLocalizations.of(context).nervousDifferentMessage);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        emailSignIn.SignUpWithaNewEmailAndPassword(
                            context,
                            emailController.text,
                            passwordController.text,
                            userNameController.text);
                      }
                    }),
                  if (widget.isUserSignIn)
                    buttonItem("assets/icon/demon.svg", AppLocalizations.of(context).yourTurnNow, 25,
                        () {
                      final emailSignIn = EmailSignIn();
                      if (emailController.text == "" ||
                          passwordController.text == "") {
                        EachDaysUtils.showSpecificToast(
                            AppLocalizations.of(context).enterYourCredentials);
                      } else {
                        emailSignIn.loginWithYourEmail(context,
                            emailController.text, passwordController.text);
                      }
                    }),
                  GFButton(
                    onPressed: () => {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignInPage()))
                    },
                    hoverColor: Colors.orange,
                    color: Colors.black,
                    icon: const Icon(Icons.arrow_back, color: Colors.orange),
                    text: AppLocalizations.of(context).preferToConnectAnotherWay,
                  ),
                ]))));
  }

  Widget buttonItem(
      String imagePath, String buttonName, double size, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 60,
        height: 60,
        child: Card(
          elevation: 8,
          color: Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(
                width: 1,
                color: Colors.grey,
              )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                imagePath,
                height: size,
                width: size,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                buttonName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget textItem(
      String name, TextEditingController controller, bool obsecureText) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 70,
      height: 55,
      child: TextFormField(
        controller: controller,
        obscureText: obsecureText,
        style: const TextStyle(
          fontSize: 17,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          labelText: name,
          labelStyle: const TextStyle(
            fontSize: 17,
            color: Colors.white,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              width: 1.5,
              color: Colors.amber,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              width: 1,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget colorButton(String name) {
    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width - 90,
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: const LinearGradient(colors: [
            Color.fromARGB(255, 0, 0, 0),
            Color.fromARGB(255, 255, 0, 0),
            Color.fromARGB(255, 0, 0, 0),
          ]),
        ),
        child: Center(
          child: circular
              ? const CircularProgressIndicator()
              : Text(name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  )),
        ),
      ),
    );
  }
}
