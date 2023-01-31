import 'package:eachday/homescreen.dart';
import 'package:eachday/services/handleFireBaseDB.dart';
import 'package:eachday/utils/eachdayutils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailSignIn extends ChangeNotifier {
  final handleFireBaseDB _baseDB = handleFireBaseDB();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future loginWithYourEmail(
      BuildContext buildContext, String email, String password) async {
    EachDaysUtils.verboseIt(
        "The user is trying to connect with his email/password ");

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await Future.value(
                _baseDB.saveConnectedUsersData(userCredential.user!,""))
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
                          {
                            EachDaysUtils.verboseIt(
                                "UserId is null while SignIn Email")
                          }
                      })
                });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        EachDaysUtils.verboseIt('No user found for that email.');
        SnackBar snackBar = EachDaysUtils.ShowSnackBar(
            "D'où tu sors ce joueur ? je ne le connais pas !👺 🔥");
        ScaffoldMessenger.of(buildContext).showSnackBar(snackBar);
      } else if (e.code == 'wrong-password') {
        EachDaysUtils.verboseIt('Wrong password provided for that user.');
        SnackBar snackBar = EachDaysUtils.ShowSnackBar(
            "hmm.. Mauvais mot de passe, reveilles-toi !👺 🔥");
        ScaffoldMessenger.of(buildContext).showSnackBar(snackBar);
      }
    }
  }

  Future SignUpWithaNewEmailAndPassword(BuildContext buildContext, String email,
      String password, String username) async {
    try {
      await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((authResult) => {
                EachDaysUtils.verboseIt("user created" + email),
                _baseDB
                    .saveConnectedUsersData(authResult.user!, username)
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
                                  {
                                    EachDaysUtils.verboseIt(
                                        "UserId is null while signUp email")
                                  }
                              })
                        })
              });
    } on FirebaseAuthException catch (e) {
      EachDaysUtils.verboseIt("Found " + e.code);
      if (e.code == 'invalid-email') {
        SnackBar snackBar = EachDaysUtils.ShowSnackBar("C'est un email Ça ? ");
        ScaffoldMessenger.of(buildContext).showSnackBar(snackBar);
      }
      if (e.code == 'weak-password') {
        SnackBar snackBar = EachDaysUtils.ShowSnackBar("J'ai besoin d'un mot de passe plus long 👺");
        ScaffoldMessenger.of(buildContext).showSnackBar(snackBar);
      }
      if (e.code == 'email-already-in-use') {
        SnackBar snackBar = EachDaysUtils.ShowSnackBar("Quelq'un utilise déjà ce mail... Ça va ? 👺");
        ScaffoldMessenger.of(buildContext).showSnackBar(snackBar);
      }
    }
  }
}


//TODO
/**
 * Handle Error Message, Email accounts.
 */