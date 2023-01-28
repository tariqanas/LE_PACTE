import 'package:eachday/services/handleFireBaseDB.dart';
import 'package:eachday/utils/eachdayutils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../homescreen.dart';

class FacebookSignInProvider extends ChangeNotifier {
  final handleFireBaseDB _baseDB = handleFireBaseDB();

  Future signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken.token);

    // Once signed in, return the UserCredential
    UserCredential credentials = await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential);
    if (credentials.user != null) {
      EachDaysUtils.verboseIt(
          "Got user" + credentials.user!.displayName.toString());
    }
  }
}
