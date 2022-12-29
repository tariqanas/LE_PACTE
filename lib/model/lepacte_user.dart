import 'package:eachday/model/lepacte_roles.dart';

// ignore: camel_case_types
class lePacteUser {
  late String id;
  late String username;
  late String previousChallenge;
  late String currentChallenge;
  late String urlOfPictureTakenToday;
  late DateTime creationTime;
  late DateTime lastSignInTime;
  late DateTime dateOfLastRefusedChallenge;
  late int howManyTimesUserRefused;
  String role = lePacteRoles.theRooky.name;
  int streak = 0;
  bool didUserSendAPictureToday = false;
  bool refusedChallengeToday = false;
  bool userBlocked = false;
}


// On va avoir un répértoire Photos : 
// Qui va contenirr NomUser_ChallengeID_Date.
// Et c'est dans l'envoie ou un va config ça.