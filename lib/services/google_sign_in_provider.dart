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
          "User exists, saving user (in google provider)");

      await Future.value(_baseDB.saveConnectedUsersData(result.user!))
          .then((processedUser) => {
                Future.delayed(const Duration(seconds: 1), () {
                  EachDaysUtils.showRandomToast();
                }).then((value) => {
                      if (processedUser.id != "")
                        {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen(
                                      title: "Le Pacte  ✌🏼👺",
                                      connectedUser: processedUser)))
                        }
                      else
                        {EachDaysUtils.verboseIt("UserId is null")}
                    })
              });
    }
  }
}
