import 'dart:io';

import 'package:eachday/model/lepacte_user.dart';
import 'package:eachday/services/CameraPage.dart';
import 'package:eachday/services/get_today_order.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'globalvars/globalvars.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:camera/camera.dart';
import 'package:eachday/utils/eachdayutils.dart';

import 'services/handleFireBaseDB.dart';
import 'services/notificationService.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title, required this.connectedUser})
      : super(key: key);

  final String title;
  final lePacteUser connectedUser;

  @override
  State<HomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<HomeScreen> {
  final handleFireBaseDB handledb = handleFireBaseDB();

  final CountDownController _countDownController = CountDownController();
  late final NotificationService notificationService;
  @override
  void initState() {
    super.initState();

    _verifyIfUserIsEligibleToPlayToday(widget.connectedUser)
        .then((eligible) => {
              EachDaysUtils.verboseIt("Got value , " + eligible.toString()),
              if (eligible)
                {
                  notificationService = NotificationService(),
                  notificationService.initializePlatformNotifications(),
                  EachDaysUtils.playTicTacSound(),
                  listenToNotificationStream(),
                  EachDaysUtils.howMuchTimeLeftAccordingToCurrentTime(),
                  _verifyIfCountDownHit10MinutesOrNo(),
                  Future<String>.delayed(const Duration(seconds: 2),
                      () => 'Chargement du défi.').then((value) async {
                    debugPrint("Fetching order for " +
                        widget.connectedUser.id +
                        (" " + widget.connectedUser.username));
                    await fetchOrder(widget.connectedUser)
                        .then((value) => setState(() {
                              widget.connectedUser.currentChallenge = value;
                            }));
                  })
                }
            });
  }

  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        EachDaysUtils.verboseIt("10 minute notification sent");
      });

  Future<String> fetchOrder(lePacteUser connectedUser) async {
    DateTime currentChallengeDate =
        DateUtils.dateOnly(connectedUser.getDateOfLastSavedChallenge);
    DateTime todaysDate = DateUtils.dateOnly(DateTime.now());

    if (connectedUser.currentChallenge == "") {
      await const GetTodayOrderService().getTodayOrder().then(
            (currentchallenge) => {
              handledb.saveConnectedUserChallenge(
                  currentchallenge,
                  connectedUser.getPreviousChallenge,
                  connectedUser,
                  DateTime.now()),
              connectedUser.currentChallenge = currentchallenge.toString()
            },
          );
    } else if (connectedUser.currentChallenge != "") {
      if (currentChallengeDate.isAtSameMomentAs(todaysDate) &&
          (connectedUser.didUserSendAPictureToday == "false" &&
              connectedUser.refusedChallengeToday == "false")) {
        return Future.value(connectedUser.currentChallenge);
      } else if (currentChallengeDate.isBefore(todaysDate)) {
        await const GetTodayOrderService()
            .getTodayOrder()
            .then((newChallenge) => {
                  handledb.saveConnectedUserChallenge(
                      newChallenge,
                      connectedUser.currentChallenge,
                      connectedUser,
                      DateTime.now()),
                  connectedUser.currentChallenge = newChallenge,
                });

        return connectedUser.getCurrentChallenge.toString();
      }
    }
    if (currentChallengeDate.isAtSameMomentAs(todaysDate) &&
        (connectedUser.refusedChallengeToday == "true")) {
      connectedUser.streak = 0;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HomeScreen(title: "Faible ! 👎 ", connectedUser: connectedUser),
        ),
      );
    }
    return connectedUser.currentChallenge;
  }

  Widget _proofButton({required String title, VoidCallback? onPressed}) {
    return Flexible(
      child: FloatingActionButton.extended(
        icon: const Icon(Icons.add_a_photo_rounded),
        onPressed: onPressed,
        label: const Text('Accepter 👑'),
        backgroundColor: Colors.black,
        heroTag: "takePictureButton",
      ),
    );
  }

  Widget _rejectButton({required String title, VoidCallback? onPressed}) {
    return Flexible(
      child: FloatingActionButton.extended(
        icon: const Icon(Icons.cancel),
        onPressed: onPressed,
        label: const Text('Refuser  🏳️'),
        backgroundColor: Colors.black,
        heroTag: "runButton",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? nullableUserPicture = FirebaseAuth.instance.currentUser?.photoURL;
    String? nullableUserUsername =
        FirebaseAuth.instance.currentUser?.displayName;
    String userPicture = "";
    String userName = "";
    if (nullableUserPicture != null) {
      userPicture = nullableUserPicture;
    }
    if (nullableUserUsername != null) {
      userName = nullableUserUsername;
    }

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          title: Row(children: [
            const Expanded(child: Text("🇫🇷")),
            Text("🔥 " + userName.toUpperCase() + " 🔥  "),
            ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  userPicture,
                  repeat: ImageRepeat.noRepeat,
                  fit: BoxFit.fitWidth,
                  height: 55,
                ))
          ]),
          automaticallyImplyLeading: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (widget.connectedUser.refusedChallengeToday == "true")
              Text(GlobalVars.weakMessage,
                  style: const TextStyle(
                      color: Colors.red,
                      fontSize: 40,
                      fontWeight: FontWeight.bold)),
            if (widget.connectedUser.refusedChallengeToday == "false")
              const Text("Aujourd'hui, tu dois  :",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            if (widget.connectedUser.refusedChallengeToday == "false")
              Text(
                  widget.connectedUser.currentChallenge == ''
                      ? '⌛.👹.⌛ '
                      : widget.connectedUser.currentChallenge + ' 🔥',
                  softWrap: false,
                  style: const TextStyle(color: Colors.white, fontSize: 19)),
            if (widget.connectedUser.refusedChallengeToday == "false")
              CircularCountDownTimer(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height / 2,
                  initialDuration: 0,
                  controller: _countDownController,
                  textStyle: const TextStyle(color: Colors.red, fontSize: 45),
                  isReverse: true,
                  isTimerTextShown: true,
                  autoStart: true,
                  onStart: () {
                    /*  EachDaysUtils.verboseIt(
                        'Countdown started' + _countDownController.getTime()); */
                  },
                  onComplete: () {
                    debugPrint('countdown finished 24h');
                    _refuseTheChallenge();
                    EachDaysUtils.showEndingToast(true);
                    notificationService.showLocalNotification(
                        id: 1,
                        title: "Faible👹 ",
                        body: "ton score repasse à 0. Comme toi.👎 ",
                        payload: "ton score repasse à 0. Comme toi.👎 ");
                  },
                  duration: GlobalVars.timeLeft,
                  fillColor: Colors.red,
                  ringColor: Colors.redAccent),
            if (widget.connectedUser.refusedChallengeToday == "false")
              const Text('☝ Don\'t lose it !',
                  softWrap: false,
                  style: TextStyle(color: Colors.white, fontSize: 19)),
            if (widget.connectedUser.refusedChallengeToday == "true")
              Text(GlobalVars.looserMessage,
                  softWrap: false,
                  style: const TextStyle(color: Colors.white, fontSize: 19)),
            Text(
                '⚡ Your Streak is : ' +
                    widget.connectedUser.getStreak.toString() +
                    ' ⚡',
                softWrap: false,
                style: const TextStyle(color: Colors.white, fontSize: 19)),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.connectedUser.refusedChallengeToday == "false") ...[
            _rejectButton(
                title: "refuse", onPressed: () => _refuseTheChallenge()),
            _proofButton(
                title: "proof",
                onPressed: () => _openAcceptChallenge(widget.connectedUser)),
          ]
        ],
      ),
    );
  }

  _openAcceptChallenge(lePacteUser connectedUser) async {
    GlobalVars.timeLeft = EachDaysUtils.convertTimeDurationToTimeStamp(
        _countDownController.getTime());
    GlobalVars.playerAccepted = true;
    await availableCameras().then(
      (value) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CameraPage(cameras: value, connectedUser: connectedUser),
        ),
      ),
    );
  }

  _refuseTheChallenge() async {
    _countDownController.restart();
    EachDaysUtils.stopTicTacSound();
    await handledb.sendProofToTheDevilOrEscape(widget.connectedUser, false);
    setState(() {
      widget.connectedUser.refusedChallengeToday = "true";
    });
  }

  _verifyIfCountDownHit10MinutesOrNo() {
    if (GlobalVars.timeLeft <= 600) {
      EachDaysUtils.showEndingToast(false);
      notificationService.showLocalNotification(
          id: 0,
          title: 'Le Pacte 👹 ',
          body: 'Il te reste juste 10 minutes 👹⏱️ ',
          payload: 'Il te reste juste 10 minutes 👹⏱️');
    }
  }

  Future _verifyIfUserIsEligibleToPlayToday(lePacteUser pacteUser) async {
    EachDaysUtils.verboseIt("I'am here 0 ");
    if (pacteUser.refusedChallengeToday == "false" &&
        DateUtils.dateOnly(pacteUser.dateOfLastRefusedChallenge)
            .isAtSameMomentAs(DateUtils.dateOnly(DateTime.now())) &&
        pacteUser.didUserSendAPictureToday == "false" &&
        DateUtils.dateOnly(pacteUser.dateOfLastSavedChallenge)
            .isAtSameMomentAs(DateUtils.dateOnly(DateTime.now()))) {
              EachDaysUtils.verboseIt("I'am here 1 ");
      return Future.value(true);
    }
    if (pacteUser.refusedChallengeToday == "true" &&
        DateUtils.dateOnly(pacteUser.dateOfLastRefusedChallenge)
            .isAtSameMomentAs(DateUtils.dateOnly(DateTime.now()))) {
              EachDaysUtils.verboseIt("I'am here 2");
      return Future.value(false);
    }
    if (pacteUser.didUserSendAPictureToday == "true" &&
        pacteUser.dateOfLastSavedChallenge
            .isAtSameMomentAs(DateUtils.dateOnly(DateTime.now()))) {
              EachDaysUtils.verboseIt("I'am here 3 ");
      return Future.value(false);
    }
    if (pacteUser.refusedChallengeToday == "true" &&
        DateUtils.dateOnly(pacteUser.dateOfLastRefusedChallenge)
            .isBefore(DateUtils.dateOnly(DateTime.now()))) {
              EachDaysUtils.verboseIt("I'am here 4 ");
      await handledb
          .resetGamingPossibilityStatus(pacteUser)
          .then((value) => {});
      return Future.value(true);
    }

    if (pacteUser.didUserSendAPictureToday == "true" &&
        DateUtils.dateOnly(pacteUser.dateOfLastSavedChallenge)
            .isBefore(DateUtils.dateOnly(DateTime.now()))) {
      await handledb
          .resetGamingPossibilityStatus(pacteUser)
          .then((value) => {});
EachDaysUtils.verboseIt("I'am here 5 ");
      return Future.value(true);
    }
EachDaysUtils.verboseIt("I'am here 6 ");
    return Future.value(false);
  }
}
