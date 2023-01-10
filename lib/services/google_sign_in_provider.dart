import 'package:eachday/model/lepacte_user.dart';
import 'package:eachday/services/handleFireBaseDB.dart';
import 'package:eachday/utils/eachdayutils.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../homescreen.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final handleFireBaseDB _baseDB = handleFireBaseDB();

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
      EachDaysUtils.verboseIt(
          "User exists, saving user..  (in google provider)");

      lePacteUser foundOrNotUser =
          await Future.value(_baseDB.saveConnectedUsersData(result.user!));

        Future.delayed(const Duration(seconds: 1), () {
          EachDaysUtils.showRandomToast();

          EachDaysUtils.debugIt(
              "Here is your user " + foundOrNotUser.streak.toString());
          if (foundOrNotUser.id != null) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(
                        title: "Le Pacte  ✌🏼👺", streak: foundOrNotUser.streak)));
          }
        });
      
    }
  }
}
