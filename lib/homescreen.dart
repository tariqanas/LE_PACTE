import 'dart:io';

import 'package:eachday/model/lepacte_user.dart';
import 'package:eachday/services/CameraPage.dart';
import 'package:eachday/services/get_today_order.dart';
import 'package:eachday/signInScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/locale.dart';
import 'dart:async';
import 'globalvars/globalvars.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:camera/camera.dart';
import 'package:eachday/utils/eachdayutils.dart';

import 'services/handleFireBaseDB.dart';
import 'services/notificationService.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:translator/translator.dart';

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
  final translator = GoogleTranslator();
  @override
  void initState() {
    super.initState();
    bool isUserEligibleToplayToday = false;

    _verifyIfUserIsEligibleToPlayToday(widget.connectedUser).then((value) => {
          isUserEligibleToplayToday = value,
          if (isUserEligibleToplayToday)
            {
              notificationService = NotificationService(),
              notificationService.initializePlatformNotifications(),
              EachDaysUtils.playTicTacSound(),
              listenToNotificationStream(),
              _verifyIfCountDownHit10MinutesOrNo(),
              fetchOrder(widget.connectedUser).then((value) => setState(() {
                    translator
                        .translate(value,
                            from: 'fr',
                            to: Localizations.localeOf(context).languageCode)
                        .then((translated) => {
                              EachDaysUtils.verboseIt(translated.text),
                              widget.connectedUser.currentChallenge =
                                  translated.text,
                              widget.connectedUser.refusedChallengeToday =
                                  "false",
                            })
                        .whenComplete(() => setState(() {}));
                  }))
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
      } else if (currentChallengeDate.isBefore(todaysDate) &&
          currentChallengeDate.year != 1970) {
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
          builder: (context) => HomeScreen(
              title: AppLocalizations.of(context).weakness,
              connectedUser: connectedUser),
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
        label: Text(AppLocalizations.of(context).acceptChallenge),
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
        label: Text(AppLocalizations.of(context).refuseChallenge),
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
    String userPicture = "assets/icon/demon.svg";
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
          title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Expanded(
                flex: 0,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: nullableUserPicture != null
                        ? Image.network(
                            userPicture,
                            repeat: ImageRepeat.noRepeat,
                            fit: BoxFit.fitWidth,
                            height: 55,
                          )
                        : SvgPicture.asset(userPicture, fit: BoxFit.fitWidth))),
            Expanded(
                flex: 1,
                child: Text(
                  // ignore: prefer_interpolation_to_compose_strings
                  " 🔥 " +
                      widget.connectedUser.username.toUpperCase() +
                      " 🔥   ",
                  textAlign: TextAlign.center,
                )),
            logoutButtona(
                title: AppLocalizations.of(context).logoutAreYouSure,
                onPressed: () => {
                      CoolAlert.show(
                          context: context,
                          title: AppLocalizations.of(context).logoutAreYouSure,
                          type: CoolAlertType.confirm,
                          text:
                              AppLocalizations.of(context).doYouReallyWantToGo,
                          confirmBtnText: AppLocalizations.of(context).yes,
                          cancelBtnText: AppLocalizations.of(context).no,
                          cancelBtnTextStyle: TextStyle(color: Colors.black),
                          backgroundColor:
                              const Color.fromARGB(255, 117, 15, 15),
                          confirmBtnColor:
                              const Color.fromARGB(255, 117, 15, 15),
                          animType: CoolAlertAnimType.rotate,
                          onConfirmBtnTap: () async {
                            Navigator.pop(context);
                            await Future.delayed(
                                const Duration(milliseconds: 1000));

                            await CoolAlert.show(
                                    context: context,
                                    title: "pfff...",
                                    type: CoolAlertType.success,
                                    backgroundColor:
                                        const Color.fromARGB(255, 117, 15, 15),
                                    text: AppLocalizations.of(context).byeOrNot)
                                .then((value) => {signOut(context)});
                          })
                    }),
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
              Text(AppLocalizations.of(context).todayYouMust,
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
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
                    EachDaysUtils.showEndingToast(true, context);
                    notificationService.showLocalNotification(
                        id: 1,
                        title: AppLocalizations.of(context).weaknessWithEvil,
                        body: AppLocalizations.of(context).scoreGoesBackToZero,
                        payload:
                            AppLocalizations.of(context).scoreGoesBackToZero);
                  },
                  duration:
                      EachDaysUtils.howMuchTimeLeftAccordingToCurrentTime(),
                  fillColor: Colors.red,
                  ringColor: Colors.redAccent),
            if (widget.connectedUser.refusedChallengeToday == "false")
              Text(AppLocalizations.of(context).dontLoseYourScore,
                  softWrap: false,
                  style: const TextStyle(color: Colors.white, fontSize: 19)),
            if (widget.connectedUser.refusedChallengeToday == "true")
              Text(GlobalVars.looserMessage,
                  softWrap: false,
                  style: const TextStyle(color: Colors.white, fontSize: 19)),
            Text(
                AppLocalizations.of(context).sumOfPoints +
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
                title: AppLocalizations.of(context).refuseButton,
                onPressed: () => _refuseTheChallenge()),
            _proofButton(
                title: AppLocalizations.of(context).proofButton,
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
      EachDaysUtils.showEndingToast(false, context);
      notificationService.showLocalNotification(
          id: 0,
          title: AppLocalizations.of(context).notificationTitle,
          body: AppLocalizations.of(context).onlyTenMinutesLeft,
          payload: AppLocalizations.of(context).onlyTenMinutesLeft);
    }
  }

  Future<bool> _verifyIfUserIsEligibleToPlayToday(lePacteUser pacteUser) async {
    if (pacteUser.refusedChallengeToday == "false" &&
        DateUtils.dateOnly(pacteUser.dateOfLastRefusedChallenge)
            .isAtSameMomentAs(DateUtils.dateOnly(DateTime.now())) &&
        pacteUser.didUserSendAPictureToday == "false" &&
        DateUtils.dateOnly(pacteUser.dateOfLastSavedChallenge)
            .isAtSameMomentAs(DateUtils.dateOnly(DateTime.now()))) {
      EachDaysUtils.verboseIt("I'am here 1 ");
      return true;
    }
    if (pacteUser.refusedChallengeToday == "true" &&
        DateUtils.dateOnly(pacteUser.dateOfLastRefusedChallenge)
            .isAtSameMomentAs(DateUtils.dateOnly(DateTime.now()))) {
      EachDaysUtils.verboseIt("I'am here 2");
      return false;
    }
    if (pacteUser.didUserSendAPictureToday == "true" &&
        pacteUser.dateOfLastSavedChallenge
            .isAtSameMomentAs(DateUtils.dateOnly(DateTime.now()))) {
      EachDaysUtils.verboseIt("I'am here 3 ");
      return false;
    }
    if (pacteUser.refusedChallengeToday == "true" &&
        DateUtils.dateOnly(pacteUser.dateOfLastRefusedChallenge)
            .isBefore(DateUtils.dateOnly(DateTime.now()))) {
      EachDaysUtils.verboseIt("I'am here 4 ");
      await handledb.resetGamingPossibilityStatus(pacteUser);
      return true;
    }

    if (pacteUser.didUserSendAPictureToday == "true" &&
        DateUtils.dateOnly(pacteUser.dateOfLastSavedChallenge)
            .isBefore(DateUtils.dateOnly(DateTime.now()))) {
      await handledb
          .resetGamingPossibilityStatus(pacteUser)
          .then((value) => {});
      EachDaysUtils.verboseIt("I'am here 5 ");
      return true;
    }
    EachDaysUtils.verboseIt("I'am here 6 ");
    return true;
  }

  Widget logoutButtona({required String title, VoidCallback? onPressed}) {
    return Expanded(
        flex: 0,
        child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: Color.fromARGB(255, 34, 2, 2),
          child: const Icon(Icons.power_settings_new_outlined,
              color: Colors.white),
        ));
  }

  Widget _buildButton(
      {VoidCallback? onTap, required String text, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: MaterialButton(
        color: Colors.white,
        minWidth: double.infinity,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  signOut(BuildContext context) {
    FirebaseAuth.instance.signOut().then((value) => {
          EachDaysUtils.audioPlayer.dispose(),
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInPage()),
          )
        });
  }
}
