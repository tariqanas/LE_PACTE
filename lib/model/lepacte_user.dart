import 'package:eachday/model/lepacte_roles.dart';

// ignore: camel_case_types
class lePacteUser {
  String? id;
  String? username;
  String? previousChallenge;
  String? currentChallenge;
  String? urlOfPictureTakenToday;
  DateTime? lastSignInTime;
  DateTime? dateOfLastRefusedChallenge;
  DateTime creationTime = DateTime.now();
  int? howManyTimesUserRefused;
  String role = lePacteRoles.theRooky.name;
  int streak = 0;
  bool didUserSendAPictureToday = false;
  bool refusedChallengeToday = false;
  bool userBlocked = false;
  bool didUserGivePermissionForPicturing = false;

  lePacteUser.withoutParams();

  lePacteUser(
      this.id,
      this.username,
      this.previousChallenge,
      this.currentChallenge,
      this.urlOfPictureTakenToday,
      this.creationTime,
      this.lastSignInTime,
      this.dateOfLastRefusedChallenge,
      this.howManyTimesUserRefused,
      this.streak,
      this.didUserSendAPictureToday,
      this.refusedChallengeToday,
      this.userBlocked,
      this.didUserGivePermissionForPicturing);
}


// On va avoir un répértoire Photos : 
// Qui va contenirr NomUser_ChallengeID_Date.
// Et c'est dans l'envoie ou un va config ça.