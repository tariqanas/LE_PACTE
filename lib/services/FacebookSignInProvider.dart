import 'package:eachday/services/handleFireBaseDB.dart';
import 'package:eachday/utils/eachdayutils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../homescreen.dart';

class FacebookSignInProvider extends ChangeNotifier {
  final handleFireBaseDB _baseDB = handleFireBaseDB();

  Future signInWithFacebook(BuildContext buildContext) async {
    final LoginResult loginResult = await FacebookAuth.instance
        .login(permissions: ['email', 'public_profile']);

    final facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    final userData = await FacebookAuth.instance.getUserData();

    try {
      final credentials = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

          if (credentials.user != null) {
               EachDaysUtils.verboseIt(
          "User exists, saving user (in Facebook provider)");

      await Future.value(_baseDB.saveConnectedUsersData(credentials.user!))
          .then((processedUser) => {
                Future.delayed(const Duration(seconds: 1), () {
                  EachDaysUtils.showRandomToast();
                }).then((value) => {
                      if (processedUser.id != "")
                        {
                          Navigator.pushReplacement(
                              buildContext,
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
    } catch (error) {
      EachDaysUtils.verboseIt(error.toString());
    }
  }
}
