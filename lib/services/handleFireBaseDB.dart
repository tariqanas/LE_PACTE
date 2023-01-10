import 'dart:async';

import 'package:eachday/model/lepacte_user.dart';
import 'package:eachday/utils/eachdayutils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// ignore: camel_case_types
class handleFireBaseDB {
  final DatabaseReference realTimeDatabaseReference =
      FirebaseDatabase.instance.ref();

  Future<lePacteUser> saveConnectedUsersData(User connectionAttemptingUser) async  {
    lePacteUser pacteUser = lePacteUser.withoutParams();
    lePacteUser maybeFoundUser = await  getLePacteUserData(connectionAttemptingUser);

    if (maybeFoundUser.getUsername == "" || maybeFoundUser.getUsername == null) {
      EachDaysUtils.verboseIt("got a value" + maybeFoundUser.username);
      realTimeDatabaseReference
          .child('users')
          .child(connectionAttemptingUser.uid)
          .set({
            'username': connectionAttemptingUser.displayName,
            'previousChallenge': pacteUser.previousChallenge,
            'currentChallenge': pacteUser.currentChallenge,
            'urlOfPictureTakenToday': pacteUser.urlOfPictureTakenToday,
            'creationTime': pacteUser.creationTime.toString(),
            'lastSignInTime': pacteUser.creationTime.toString(),
            'dateOfLastRefusedChallenge':
                pacteUser.dateOfLastRefusedChallenge.toString(),
            'howManyTimesUserRefused': pacteUser.howManyTimesUserRefused,
            'role': pacteUser.role,
            'streak': pacteUser.streak,
            'didUserSendAPictureToday':
                pacteUser.didUserSendAPictureToday.toString(),
            'refusedChallengeToday': pacteUser.refusedChallengeToday.toString(),
            'userBlocked': pacteUser.userBlocked.toString(),
            'didUserGivePermissionForPicturing':
                pacteUser.didUserGivePermissionForPicturing.toString()
          })
          .then((value) => {
                EachDaysUtils.verboseIt("User" +
                    connectionAttemptingUser.uid +
                    " added to database"),
              })
          .catchError((error) {
            EachDaysUtils.debugIt("ERROOOOOOR" + error.toString());
          })
          .whenComplete(() => EachDaysUtils.verboseIt("Done Save connect"),);
    }
    return maybeFoundUser;
  }

  Future<lePacteUser> getLePacteUserData(User connectionAttemptingUser) async {
    EachDaysUtils.verboseIt("Getting user" + connectionAttemptingUser.uid);
    lePacteUser foundUser = lePacteUser.withoutParams();

    await realTimeDatabaseReference
        .child('users')
        .child(connectionAttemptingUser.uid)
        .get()
        .then((value) => {
              if (value.exists)
                {
                  EachDaysUtils.verboseIt(
                      'found user' + value.toString()),
                       EachDaysUtils.verboseIt(
                      'found user' + connectionAttemptingUser.uid),
                  foundUser = EachDaysUtils.googleUserToLePacteUserMapper(
                      connectionAttemptingUser, value)
                }
            })
        .catchError((onError) {
      EachDaysUtils.debugIt("Error on get" + onError.toString());
      throw Exception("Error on get");
    }).whenComplete(() => {
              EachDaysUtils.verboseIt(
                  "Finished GetLePacteUserData: " + foundUser.id.toString()),
              EachDaysUtils.debugIt("Send back" + foundUser.id.toString())
            });

    return Future.value(foundUser);
  }
}
