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
    debugPrint("Launching with credentiens");
    debugPrint(credientials.accessToken);

    UserCredential result =
        await FirebaseAuth.instance.signInWithCredential(credientials);
    /*    notifyListeners(); */

    debugPrint("Checking usaa");
    if (result.user != null) {
      debugPrint("user not null");
      debugPrint("user is " + result.user.toString());
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const HomeScreen(title: "Le Pacte  ✌🏼👺", streak: 20)));
    }
  }
}
