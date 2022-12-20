import 'package:eachday/utils/eachdayutils.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../homescreen.dart';

class GoogleSignInProvider extends ChangeNotifier {
  Future googleLogin(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credientials = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
   
    UserCredential result =
        await FirebaseAuth.instance.signInWithCredential(credientials);

    EachDaysUtils.verboseIt("Checking user ");

    if (result.user != null) {
      
       EachDaysUtils.verboseIt("User exists, switching to Main Menu..");
      
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const HomeScreen(title: "Le Pacte  ✌🏼👺", streak: 20)));
    }
  }
}
