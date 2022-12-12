import 'package:eachday/services/CameraPage.dart';
import 'package:eachday/services/get_today_order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'globalvars/globalvars.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:camera/camera.dart';
import 'package:eachday/utils/eachdayutils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title, required this.streak})
      : super(key: key);

  final String title;
  final int streak;

  @override
  State<HomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<HomeScreen> {
  static const String _weakMessage = 'You are Weak 👹';
  int streak = 0;
  bool playerAccepted = false;
  bool playerRefused = false;
  String looserMessage =
      'Loser ! Your Streak is going back to 0. \n see you tomorrow chicken. 🐔';
  Timer? timer;
  final CountDownController _countDownController = CountDownController();

  @override
  void initState() {
    super.initState();
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

  Future<String> fetchOrder() async {
    if (GlobalVars.todayOrder == '' && !playerRefused) {
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
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
          automaticallyImplyLeading: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (playerRefused)
              const Text(_weakMessage,
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 40,
                      fontWeight: FontWeight.bold)),
            if (!playerRefused)
              const Text("Aujourd'hui, tu dois  :",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            if (!playerRefused)
              Text(
                  GlobalVars.todayOrder == ''
                      ? '⌛.👹.⌛ '
                      : GlobalVars.todayOrder + ' 🔥',
                  softWrap: false,
                  style: const TextStyle(color: Colors.white, fontSize: 19)),
            if (!playerRefused)
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
                    debugPrint('Countdown started');
                  },
                  onComplete: () {
                    debugPrint('countdown finished 24h');
                    _refuseTheChallenge();
                    EachDaysUtils.showEndingToast(true);
                  },
                  duration: GlobalVars.timeLeft,
                  fillColor: Colors.red,
                  ringColor: Colors.redAccent),
            if (!playerRefused)
              const Text('☝ Don\'t lose it !',
                  softWrap: false,
                  style: TextStyle(color: Colors.white, fontSize: 19)),
            if (playerRefused)
              Text(looserMessage,
                  softWrap: false,
                  style: const TextStyle(color: Colors.white, fontSize: 19)),
            Text('⚡ Your Streak is : ' + streak.toString() + ' ⚡',
                softWrap: false,
                style: const TextStyle(color: Colors.white, fontSize: 19)),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!playerRefused) ...[
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
    playerAccepted = true;
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
      playerRefused = true;
      streak = 0;
      _countDownController.restart();
      EachDaysUtils.stopTicTacSound();
      GlobalVars.todayOrder = '';
    });
  }

  _verifyIfCountDownHit10MinutesOrNo() {
    if (GlobalVars.timeLeft <= 600) {
      EachDaysUtils.showEndingToast(false);
    }
  }
}
