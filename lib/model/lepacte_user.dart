// ignore_for_file: unnecessary_this

import 'package:eachday/model/lepacte_roles.dart';

// ignore: camel_case_types
class lePacteUser {
  String id = "";
  String username = "";
  String previousChallenge = "";
  String currentChallenge = "";
  String urlOfPictureTakenToday = "";
  DateTime lastSignInTime = DateTime.now();
  DateTime dateOfLastRefusedChallenge = DateTime.now();
  DateTime creationTime = DateTime.now();
  DateTime dateOfLastSavedChallenge = DateTime.now();
  int howManyTimesUserRefused = 0;
  String role = lePacteRoles.theRooky.name;
  int streak = 0;
  String didUserSendAPictureToday = "false";
  String refusedChallengeToday = "false";
  String userBlocked = "false";
  String didUserGivePermissionForPicturing = "false";

  lePacteUser.withoutParams();

  get getId => this.id;

  set setId(id) => this.id = id;

  get getUsername => this.username;

  set setUsername(username) => this.username = username;

  get getPreviousChallenge => this.previousChallenge;

  set setPreviousChallenge(previousChallenge) =>
      this.previousChallenge = previousChallenge;

  get getCurrentChallenge => this.currentChallenge;

  set setCurrentChallenge(currentChallenge) =>
      this.currentChallenge = currentChallenge;

  get getUrlOfPictureTakenToday => this.urlOfPictureTakenToday;

  set setUrlOfPictureTakenToday(urlOfPictureTakenToday) =>
      this.urlOfPictureTakenToday = urlOfPictureTakenToday;

  get getLastSignInTime => this.lastSignInTime;

  set setLastSignInTime(lastSignInTime) => this.lastSignInTime = lastSignInTime;

  get getDateOfLastRefusedChallenge => this.dateOfLastRefusedChallenge;

  set setDateOfLastRefusedChallenge(dateOfLastRefusedChallenge) =>
      this.dateOfLastRefusedChallenge = dateOfLastRefusedChallenge;

  get getCreationTime => this.creationTime;

  set setCreationTime(creationTime) => this.creationTime = creationTime;

  get getHowManyTimesUserRefused => this.howManyTimesUserRefused;

  set setHowManyTimesUserRefused(howManyTimesUserRefused) =>
      this.howManyTimesUserRefused = howManyTimesUserRefused;

  get getRole => this.role;

  set setRole(role) => this.role = role;

  get getStreak => this.streak;

  set setStreak(streak) => this.streak = streak;

  get getDidUserSendAPictureToday => this.didUserSendAPictureToday;

  set setDidUserSendAPictureToday(didUserSendAPictureToday) =>
      this.didUserSendAPictureToday = didUserSendAPictureToday;

  get getRefusedChallengeToday => this.refusedChallengeToday;

  set setRefusedChallengeToday(refusedChallengeToday) =>
      this.refusedChallengeToday = refusedChallengeToday;

  get getUserBlocked => this.userBlocked;

  set setUserBlocked(userBlocked) => this.userBlocked = userBlocked;

  get getDidUserGivePermissionForPicturing =>
      this.didUserGivePermissionForPicturing;

  set setDidUserGivePermissionForPicturing(didUserGivePermissionForPicturing) =>
      this.didUserGivePermissionForPicturing =
          didUserGivePermissionForPicturing;
  get getDateOfLastSavedChallenge => this.dateOfLastSavedChallenge;

  set setDateOfLastSavedChallenge(dateOfLastSavedChallenge) =>
      this.dateOfLastSavedChallenge = dateOfLastSavedChallenge;
}
