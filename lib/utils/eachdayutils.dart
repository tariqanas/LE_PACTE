import 'package:audioplayers/audioplayers.dart';
import 'package:eachday/model/lepacte_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:eachday/globalvars/globalvars.dart';
import 'package:logger/logger.dart';

class EachDaysUtils {
  static AudioPlayer audioPlayer = AudioPlayer();
  static String endMessage = "You're time is done ! You Lost. ⚡";
  static String almostEndMessage = "Less then 10 minutes left.⏱️";
  static String twitterApiClientID = "ckEzS1VBcnJLMExmVnNfUzZMb3k6MTpjaQ";
  static String twitterClientSecret =
      "qRDICZ-kbdF7sqfsUEqLP2SUMfeX7xgpmPRF0sEV-9q0Zlo-hD";

  static verboseIt(String verboseMessage) {
    var logger = Logger(printer: PrettyPrinter(methodCount: 0));
    logger.v(verboseMessage);
  }

  static debugIt(String debugMessage) {
    var logger = Logger(printer: PrettyPrinter(methodCount: 0));
    logger.d(debugMessage);
  }

  void initAudioPlayer() {
    audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  static int convertTimeDurationToTimeStamp(String timeDuration) {
    var hhmmsstoseconds = timeDuration.split(":");
    int hourstoInt = int.parse(hhmmsstoseconds[0]);
    int minutestoInt = int.parse(hhmmsstoseconds[1]);
    int secondstoInt = 0;
    if (hhmmsstoseconds.length == 3) {
      secondstoInt = int.parse(hhmmsstoseconds[2]);
    }
    return hourstoInt * 3600 + minutestoInt * 60 + secondstoInt;
  }

  static Future<void> playTicTacSound() async {
    audioPlayer.play(AssetSource("timer_sound.mp3"));
  }

  static Future<void> stopTicTacSound() async {
    audioPlayer.stop();
    audioPlayer.dispose();
  }

  static showEndingToast(bool timerEnded) {
    Fluttertoast.showToast(
        msg: timerEnded ? endMessage : almostEndMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM_LEFT,
        backgroundColor: Colors.red,
        timeInSecForIosWeb: 1,
        textColor: Colors.black,
        fontSize: 20.0);
  }

  static showRandomToast() {
    Fluttertoast.showToast(
        msg: "..⌛.. ",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Color.fromARGB(255, 238, 72, 60),
        timeInSecForIosWeb: 1,
        textColor: Color.fromARGB(255, 255, 255, 255),
        fontSize: 20.0);
  }

  static takeaPictureFirst() {
    Fluttertoast.showToast(
        msg: "Réfléchis 😈! ",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        timeInSecForIosWeb: 1,
        textColor: Color.fromARGB(255, 233, 2, 2),
        fontSize: 20.0);
    return null;
  }

  static howMuchTimeLeftAccordingToCurrentTime() {
    var format = DateFormat("HH:mm:ss");
    var one = format.parse("23:59:59");
    var two = format.parse(DateTime.now().hour.toString() +
        ":" +
        DateTime.now().minute.toString() +
        ":" +
        DateTime.now().second.toString());

    GlobalVars.timeLeft = one.difference(two).inSeconds.toInt();
    return GlobalVars.timeLeft;
  }

  getCurrentConnectedUser() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return currentUser;
    }
    verboseIt("There is no current user");
  }

  static lePacteUser googleUserToLePacteUserMapper(
      User connectionAttemptingUser, DataSnapshot snapshot) {
    lePacteUser pacteUser = lePacteUser.withoutParams();
    if (snapshot.value != null) {
      final data = snapshot.value as Map;
      pacteUser.setId = connectionAttemptingUser.uid;
      pacteUser.setUsername = connectionAttemptingUser.displayName;
      pacteUser.setCreationTime = DateTime.parse(data['creationTime']);
      pacteUser.setPreviousChallenge = data['previousChallenge'];
      pacteUser.currentChallenge =
          data['previousChallenge'] != null ? data['currentChallenge'] : null;
      pacteUser.urlOfPictureTakenToday = data['urlOfPictureTakenToday'];
      pacteUser.lastSignInTime = DateTime.parse(data['lastSignInTime']);
      pacteUser.dateOfLastRefusedChallenge =
          DateTime.parse(data['dateOfLastRefusedChallenge']);
      pacteUser.profilePicture = connectionAttemptingUser.photoURL!;
      pacteUser.howManyTimesUserRefused = data['howManyTimesUserRefused'];
      pacteUser.role = data['role'];
      pacteUser.streak = data['streak'] as int;
      pacteUser.didUserSendAPictureToday = data['didUserSendAPictureToday'];
      pacteUser.refusedChallengeToday = data['refusedChallengeToday'];
      pacteUser.userBlocked = data['userBlocked'];
      pacteUser.didUserGivePermissionForPicturing =
          data['didUserGivePermissionForPicturing'];
      pacteUser.dateOfLastSavedChallenge = data['dateOfLastSavedChallenge'] =
          DateTime.parse(data['dateOfLastSavedChallenge']);
    }

    return pacteUser;
  }

  static String parseBoolToStringForJson(bool bool) {
    return bool.toString().toLowerCase();
  }
}
