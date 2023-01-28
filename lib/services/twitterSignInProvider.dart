import 'package:eachday/homescreen.dart';
import 'package:eachday/services/handleFireBaseDB.dart';
import 'package:eachday/utils/eachdayutils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';

class TwitterSignInProvider extends ChangeNotifier {
  Future loginWithTwitter(BuildContext context) async {
    final handleFireBaseDB _baseDB = handleFireBaseDB();
    TwitterLoginResult _twitterLoginResult;
    TwitterLoginStatus _twitterLoginStatus;
    TwitterSession _currentUserTwitterSession;

    final TwitterLogin twitterLogin = TwitterLogin(
        consumerKey: EachDaysUtils.twitterApiClientID,
        consumerSecret: EachDaysUtils.twitterClientSecret);

    _twitterLoginResult = await twitterLogin.authorize();

    _currentUserTwitterSession = _twitterLoginResult.session;
    _twitterLoginStatus = _twitterLoginResult.status;

    if (_twitterLoginStatus == TwitterLoginStatus.loggedIn) {
      EachDaysUtils.verboseIt("GOT IT");
      _currentUserTwitterSession = _twitterLoginResult.session;
    } else {
      EachDaysUtils.verboseIt("NOT SAME");
      EachDaysUtils.verboseIt(_twitterLoginStatus.toString());
    }

    AuthCredential _authCredential = TwitterAuthProvider.credential(
        accessToken: _currentUserTwitterSession.token,
        secret: _currentUserTwitterSession.secret);

    var twitterUser =
        await FirebaseAuth.instance.signInWithCredential(_authCredential);

    if (twitterUser.user != null) {
      EachDaysUtils.verboseIt("User exists, saving user (in twitter provider)");

      await Future.value(_baseDB.saveConnectedUsersData(twitterUser.user!))
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

    EachDaysUtils.verboseIt("_twitterLoginResult.session.toString()");
    EachDaysUtils.verboseIt(_twitterLoginResult.session.toString());
  }
}
