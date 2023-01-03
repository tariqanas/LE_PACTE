import 'dart:convert';
import 'dart:developer';

import 'package:eachday/model/lepacte_user.dart';
import 'package:eachday/utils/eachdayutils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

// ignore: camel_case_types
class handleFireBaseDB {
  final DatabaseReference realTimeDatabaseReference =
      FirebaseDatabase.instance.ref();

  saveConnectedUsersData(User connectionAttemptingUser) async {
    String? pacteUserUID = getLePacteUserData(connectionAttemptingUser);

    if (pacteUserUID == null) {
      lePacteUser pacteUser = lePacteUser.WithoutParams();
      realTimeDatabaseReference
          .child('users')
          .child(connectionAttemptingUser.uid)
          .set({
        'username': connectionAttemptingUser.displayName,
        'previousChallenge': pacteUser.previousChallenge,
        'currentChallenge': pacteUser.currentChallenge,
        'urlOfPictureTakenToday': pacteUser.urlOfPictureTakenToday,
        'creationTime': pacteUser.creationTime.toString(),
        'lastSignInTime':pacteUser.creationTime.toString(),
        'dateOfLastRefusedChallenge': pacteUser.dateOfLastRefusedChallenge,
        'howManyTimesUserRefused': pacteUser.howManyTimesUserRefused,
        'role': pacteUser.role,
        'streak': pacteUser.streak,
        'didUserSendAPictureToday': pacteUser.didUserSendAPictureToday,
        'refusedChallengeToday': pacteUser.refusedChallengeToday,
        'userBlocked': pacteUser.userBlocked,
        'didUserGivePermissionForPicturing':
            pacteUser.didUserGivePermissionForPicturing
      }).then((value) => {
                EachDaysUtils.verboseIt(
                    "User" + connectionAttemptingUser.uid + " added to database")
              });
    }
  }

  String? getLePacteUserData(User connectionAttemptingUser) {
    EachDaysUtils.verboseIt("Getting user" + connectionAttemptingUser.uid);
    String? foundUser;
    Map<Object?, Object?> data;

    realTimeDatabaseReference
        .child('users')
        .child(connectionAttemptingUser.uid)
        .get()
        .then((value) => {
              if (value.exists)
                {
                  EachDaysUtils.verboseIt('found user' + connectionAttemptingUser.uid),
                  foundUser = connectionAttemptingUser.uid,
                }
            });
    return foundUser;
  }
}
