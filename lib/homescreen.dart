import 'dart:io';

import 'package:eachday/services/CameraPage.dart';
import 'package:eachday/services/get_today_order.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'globalvars/globalvars.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:camera/camera.dart';
import 'package:eachday/utils/eachdayutils.dart';

import 'services/notificationService.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title, required this.streak})
      : super(key: key);

  final String title;
  final int streak;

  @override
  State<HomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<HomeScreen> {
  final CountDownController _countDownController = CountDownController();
  late final NotificationService notificationService;
  @override
  void initState() {
    super.initState();
     notificationService = NotificationService();
      notificationService.initializePlatformNotifications();
    listenToNotificationStream();
    EachDaysUtils.howMuchTimeLeftAccordingToCurrentTime();
    _verifyIfCountDownHit10MinutesOrNo();
    Future<String>.delayed(
            const Duration(seconds: 2), () => 'Chargement du nouveau défi.')
        .then((String value) {
      setState(() {
        EachDaysUtils.playTicTacSound();
        fetchOrder();
      });
    });
  }

  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        EachDaysUtils.verboseIt("10 minute notification sent");
      });
  Future<String> fetchOrder() async {
    if (GlobalVars.todayOrder == '' && !GlobalVars.playerRefused) {
      return GlobalVars.todayOrder =
          await const GetTodayOrderService().getTodayOrder();
    }
    return GlobalVars.todayOrder;
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
          title: Row(children: [ const Expanded(child: Text("🇫🇷")),
            Text("🔥 "+ userName.toUpperCase() +" 🔥  "),
         ClipRRect(borderRadius: BorderRadius.circular(100),
         child: Image.network(userPicture, repeat: ImageRepeat.noRepeat,fit: BoxFit.fitWidth,height: 55,))]),
          automaticallyImplyLeading: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (GlobalVars.playerRefused)
              Text(GlobalVars.weakMessage,
                  style: const TextStyle(
                      color: Colors.red,
                      fontSize: 40,
                      fontWeight: FontWeight.bold)),
            if (!GlobalVars.playerRefused)
              const Text("Aujourd'hui, tu dois  :",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            if (!GlobalVars.playerRefused)
              Text(
                  GlobalVars.todayOrder == ''
                      ? '⌛.👹.⌛ '
                      : GlobalVars.todayOrder + ' 🔥',
                  softWrap: false,
                  style: const TextStyle(color: Colors.white, fontSize: 19)),
            if (!GlobalVars.playerRefused)
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
                    EachDaysUtils.verboseIt(
                        'Countdown started' + _countDownController.getTime());
                  },
                  onComplete: () {
                    debugPrint('countdown finished 24h');
                    _refuseTheChallenge();
                    EachDaysUtils.showEndingToast(true);
                    notificationService.showLocalNotification(id: 1, title: "Faible👹 ", body: "ton score repasse à 0. Comme toi.👎 ", payload: "ton score repasse à 0. Comme toi.👎 ");
                  },
                  duration: GlobalVars.timeLeft,
                  fillColor: Colors.red,
                  ringColor: Colors.redAccent),
            if (!GlobalVars.playerRefused)
              const Text('☝ Don\'t lose it !',
                  softWrap: false,
                  style: TextStyle(color: Colors.white, fontSize: 19)),
            if (GlobalVars.playerRefused)
              Text(GlobalVars.looserMessage,
                  softWrap: false,
                  style: const TextStyle(color: Colors.white, fontSize: 19)),
            Text('⚡ Your Streak is : ' + GlobalVars.streak.toString() + ' ⚡',
                softWrap: false,
                style: const TextStyle(color: Colors.white, fontSize: 19)),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!GlobalVars.playerRefused) ...[
            _rejectButton(
                title: "refuse", onPressed: () => _refuseTheChallenge()),
            _proofButton(
                title: "proof", onPressed: () => _openAcceptChallenge()),
          ]
        ],
      ),
    );
  }

  _openAcceptChallenge() async {
    GlobalVars.timeLeft = EachDaysUtils.convertTimeDurationToTimeStamp(
        _countDownController.getTime());
    GlobalVars.playerAccepted = true;
    await availableCameras().then(
      (value) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraPage(cameras: value),
        ),
      ),
    );
  }

  _refuseTheChallenge() {
    setState(() {
      GlobalVars.playerRefused = true;
      GlobalVars.streak = 0;
      _countDownController.restart();
      EachDaysUtils.stopTicTacSound();
      GlobalVars.todayOrder = '';
    });
  }

  _verifyIfCountDownHit10MinutesOrNo() {
    if (GlobalVars.timeLeft <= 600) {
      EachDaysUtils.showEndingToast(false);
      notificationService.showLocalNotification(
                                id: 0,
                                title: 'Le Pacte 👹 ',
                                body: 'Il te reste juste 10 minutes 👹⏱️ ',
                                payload: 'Il te reste juste 10 minutes 👹⏱️')
    }
  }

/*   _isPlayerEligibleToPlayToday() {

    if (GlobalVars.timeLeft < 0 && TodayWasAlreadSet()) {
      _refuseTheChallenge();
    }
  } */
}
