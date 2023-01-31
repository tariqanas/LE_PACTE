import 'package:eachday/services/FacebookSignInProvider.dart';
import 'package:eachday/services/emailLogin.dart';
import 'package:eachday/services/google_sign_in_provider.dart';
import 'package:eachday/utils/eachdayutils.dart';
import 'package:eachday/SignUpScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: Image.asset("assets/splash/each_day_splash.png"),
                height: 300,
              ),
              const Text(
                "Le Pacte 🤝",
                style: TextStyle(
                  fontSize: 35,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              buttonItem(
                  "assets/icon/google.svg", "Connectes-toi avec Google", 25,
                  () {
                final googleProvider =
                    Provider.of<GoogleSignInProvider>(context, listen: false);
                googleProvider.googleLogin(context);
              }),
              buttonItem(
                  "assets/icon/fbk.svg", "Connectes-toi avec Facebook", 25, () {
                final facebookProvider = FacebookSignInProvider();
                facebookProvider.signInWithFacebook(context);
              }),
              buttonItem("assets/icon/email.svg",
                  "Connectes-toi avec ton compte le pacte", 25, () {
                final emailSignIn = EmailSignIn();
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen(isUserSignIn : true)));
              }),
              colorButton("Rejoins la communauté."),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:  [
                  InkWell(
                    child: const Text(
                      " Sinon, crées un compte lePacte.",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.underline,
                        color: Colors.orangeAccent,
                        fontSize: 18,
                      ),
                    ),
                    onTap: () {
                      EachDaysUtils.verboseIt("Redirecting to Sign Up");
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen(isUserSignIn: false)));
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  InkWell(
                    child: Text(
                      " Fais ton choix ! 👹.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
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
    return Container(
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
