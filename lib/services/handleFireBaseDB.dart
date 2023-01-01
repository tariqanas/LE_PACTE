import 'package:eachday/model/lepacte_user.dart';
import 'package:eachday/utils/eachdayutils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// ignore: camel_case_types
class handleFireBaseDB {
  final DatabaseReference realTimeDatabaseReference =
      FirebaseDatabase.instance.ref();

  saveConnectedUsersData(User connectionAttemptingUser) async {
    EachDaysUtils.verboseIt("GOING TO");
    final usersRef = realTimeDatabaseReference.child('/users');
    lePacteUser pacteUser = getLePacteUserData(connectionAttemptingUser);

    if (pacteUser.id == null) {
      EachDaysUtils.verboseIt("SETTING USER");
      //TODO insert an object user not a orhpan key value
      //https://stackoverflow.com/questions/54106751/flutter-firebase-database-setobject-issue
      usersRef.set({
        'id': pacteUser.id,
        'username': pacteUser.username,
        'previousChallenge': pacteUser.previousChallenge,
        'currentChallenge': pacteUser.currentChallenge,
        'urlOfPictureTakenToday': pacteUser.urlOfPictureTakenToday,
        'creationTime': pacteUser.creationTime,
        'lastSignInTime': pacteUser.lastSignInTime,
        'dateOfLastRefusedChallenge': pacteUser.dateOfLastRefusedChallenge,
        'howManyTimesUserRefused': pacteUser.howManyTimesUserRefused,
        'role': pacteUser.role,
        'streak': pacteUser.streak,
        'didUserSendAPictureToday': pacteUser.didUserSendAPictureToday,
        'refusedChallengeToday': pacteUser.refusedChallengeToday,
        'userBlocked': pacteUser.userBlocked,
        'didUserGivePermissionForPicturing':
            pacteUser.didUserGivePermissionForPicturing
      });
      EachDaysUtils.verboseIt("The user is add" + pacteUser.id.toString() + " the database. ");
    }

    
  }

//TODO correct this.
  getLePacteUserData(User connectionAttemptingUser) async {
    lePacteUser? foundUser;
    final usersRef = realTimeDatabaseReference.child('/users');
    final snapshot = await usersRef
        .child(connectionAttemptingUser.uid)
        .get();

    if (snapshot.exists) {
      EachDaysUtils.verboseIt("Found somehing");
      EachDaysUtils.verboseIt(snapshot.value.toString());
      return snapshot.value;
    }
    EachDaysUtils.verboseIt("The user" +
        connectionAttemptingUser.displayName.toString() +
        "doesn't exist");
    return Future.error("The user doesn't exist");
  }
}
