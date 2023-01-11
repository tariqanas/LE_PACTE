import 'dart:async';

import 'package:eachday/model/lepacte_user.dart';
import 'package:eachday/utils/eachdayutils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class handleFireBaseDB {
  handleFireBaseDB();
  final DatabaseReference realTimeDatabaseReference =
      FirebaseDatabase.instance.ref();

  Future<lePacteUser> saveConnectedUsersData(
      User connectionAttemptingUser) async {
    lePacteUser maquetteUser = lePacteUser.withoutParams();
    lePacteUser pacteUser = await getLePacteUserData(connectionAttemptingUser);

    if (pacteUser.getUsername == "" || pacteUser.getUsername == null) {
      EachDaysUtils.verboseIt("user not in firebaseDB");
      realTimeDatabaseReference
          .child('users')
          .child(connectionAttemptingUser.uid)
          .set({
            'id': connectionAttemptingUser.uid,
            'username': connectionAttemptingUser.displayName,
            'previousChallenge': maquetteUser.previousChallenge,
            'currentChallenge': maquetteUser.currentChallenge,
            'urlOfPictureTakenToday': maquetteUser.urlOfPictureTakenToday,
            'creationTime': maquetteUser.creationTime.toString(),
            'lastSignInTime': maquetteUser.creationTime.toString(),
            'dateOfLastRefusedChallenge':
                maquetteUser.dateOfLastRefusedChallenge.toString(),
            'howManyTimesUserRefused': maquetteUser.howManyTimesUserRefused,
            'role': maquetteUser.role,
            'streak': maquetteUser.streak,
            'didUserSendAPictureToday':
                maquetteUser.didUserSendAPictureToday.toString(),
            'refusedChallengeToday':
                maquetteUser.refusedChallengeToday.toString(),
            'userBlocked': maquetteUser.userBlocked.toString(),
            'didUserGivePermissionForPicturing':
                maquetteUser.didUserGivePermissionForPicturing.toString(),
            'dateOfLastSavedChallenge':
                maquetteUser.dateOfLastSavedChallenge.toString()
          })
          .then((value) => {
                EachDaysUtils.verboseIt("User" +
                    connectionAttemptingUser.uid +
                    " added to database"),
                pacteUser.id = connectionAttemptingUser.uid
              })
          .catchError((error) {
            EachDaysUtils.debugIt("Error saving user" + error.toString());
          })
          .whenComplete(
            () => EachDaysUtils.verboseIt("Done Save connect"),
          );
    }
    return pacteUser;
  }

  Future<lePacteUser> getLePacteUserData(User connectionAttemptingUser) async {
    EachDaysUtils.verboseIt(
        "getLePacteUserData" + connectionAttemptingUser.uid);
    lePacteUser foundUser = lePacteUser.withoutParams();

    await realTimeDatabaseReference
        .child('users')
        .child(connectionAttemptingUser.uid)
        .get()
        .then((value) => {
              if (value.exists)
                {
                  EachDaysUtils.verboseIt(
                      'found user' + connectionAttemptingUser.uid),
                  foundUser = EachDaysUtils.googleUserToLePacteUserMapper(
                      connectionAttemptingUser, value)
                }
            })
        .catchError((onError) {
      EachDaysUtils.debugIt("Error on getLePacteUserData" + onError.toString());
      throw Exception("Error on getLePacteUserData");
    }).whenComplete(() => {
              EachDaysUtils.verboseIt(
                  "Finished GetLePacteUserData: " + foundUser.id.toString())
            });
    return Future.value(foundUser);
  }

  saveConnectedUserChallenge(String currentChallenge, String oldChallenge,
      lePacteUser pacteUser, DateTime savingDate) {
    realTimeDatabaseReference
        .child('users')
        .child(pacteUser.id)
        .update({
          'currentChallenge': currentChallenge,
          'previousChallenge': oldChallenge,
          'dateOfLastSavedChallenge': savingDate.toString()
        })
        .then((value) => EachDaysUtils.verboseIt(
            "Save connectedChallenge for " + pacteUser.id))
        .onError((error, stackTrace) => {
              EachDaysUtils.verboseIt(
                  "Couldn't save ConnectedUserChallenge" + error.toString())
            });
  }
}
