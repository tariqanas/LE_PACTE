import 'package:eachday/homescreen.dart';
import 'package:eachday/services/handleFireBaseDB.dart';
import 'package:eachday/utils/eachdayutils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailSignIn extends ChangeNotifier {
  final handleFireBaseDB baseDB = handleFireBaseDB();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future loginWithYourEmail(
      BuildContext context, String email, String password) async {
    EachDaysUtils.verboseIt(
        "The user is trying to connect with his email/password ");

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: "lepacte_pacte@gmail.com", password: "123456789");

      if (userCredential.user != null) {
        debugPrint("Go to homeScreen");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future SignUpWithaNewEmailAndPassword(BuildContext context, String email,
      String password, String username) async {
    firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((authResult) => {EachDaysUtils.verboseIt("user created" + email)})
        .catchError((e) {
      debugPrint("EROOOR" + e.toString());
    });
  }
}


//TODO
/**
 * Create le Pacte User after SignUp with Email
 * Go To homeScreen
 * if Sign ign , do the same Thing for Facebook & Google.
 * Handle Error Message, Email accounts.
 */