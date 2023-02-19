import 'dart:io';

import 'package:camera/camera.dart';
import 'package:eachday/homescreen.dart';
import 'package:eachday/model/lepacte_user.dart';
import 'package:eachday/services/EvidenceUploaderService.dart';
import 'package:eachday/services/handleFireBaseDB.dart';
import 'package:eachday/utils/eachdayutils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animated_button/animated_button.dart';
import 'package:getwidget/getwidget.dart';
import 'handleFireBaseDB.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  final lePacteUser connectedUser;

  const CameraPage({this.cameras, Key? key, required this.connectedUser})
      : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool pictureSent = false;
  bool pictureTaken = false;
  bool gotValidationFromAdmin = false;
  bool waitingForAdminAproval = false;
  int streak = 0;
  final imagePicker = ImagePicker();
  late CameraController controller;
  XFile? pictureFile;
  final providerUser = FirebaseAuth.instance.currentUser;
  static List<dynamic> topTenUsers = [];

  @override
  void initState() {
    super.initState();
    topTenUsers = handleFireBaseDB().getTopTenUsersByScoring();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget notNowButtonV2({required String title, onPressed}) {
    return Flexible(
      child: AnimatedButton(
        onPressed: onPressed,
        enabled: (widget.connectedUser.didUserSendAPictureToday == "false" &&
            widget.connectedUser.refusedChallengeToday == "false"),
        shadowDegree: ShadowDegree.dark,
        color: const Color.fromARGB(255, 117, 15, 15),
        height: 50,
        child: (widget.connectedUser.didUserSendAPictureToday == "true" ||
                widget.connectedUser.refusedChallengeToday == "true")
            ? Text(
                AppLocalizations.of(context).theDevilWillVerify,
                style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              )
            : Text(AppLocalizations.of(context).notNowChallenge,
                style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget okSendProofButtonV2({required String title, onPressed}) {
    return Flexible(
      child: AnimatedButton(
        enabled: (widget.connectedUser.didUserSendAPictureToday == "false" &&
            widget.connectedUser.refusedChallengeToday == "false"),
        onPressed: onPressed,
        shadowDegree: ShadowDegree.dark,
        color: const Color.fromARGB(255, 117, 15, 15),
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: (widget.connectedUser.didUserSendAPictureToday == "true" ||
                widget.connectedUser.refusedChallengeToday == "true")
            ? Text(AppLocalizations.of(context).waitingForValidation,
                style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black,
                    fontWeight: FontWeight.w500))
            : Text(AppLocalizations.of(context).sendProofToTheDevil,
                style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget okTakePictureV2({required String title, onPressed}) {
    return Flexible(
      child: AnimatedButton(
        enabled: (widget.connectedUser.didUserSendAPictureToday == "false" &&
            widget.connectedUser.refusedChallengeToday == "false"),
        onPressed: () {
          if (widget.connectedUser.didUserSendAPictureToday == "false" &&
              widget.connectedUser.refusedChallengeToday == "false") {
            onPressed();
          }
        },
        shadowDegree: ShadowDegree.dark,
        color: const Color.fromARGB(255, 117, 15, 15),
        height: 50,
        child: (widget.connectedUser.didUserSendAPictureToday == "true" ||
                widget.connectedUser.refusedChallengeToday == "true")
            ? Text(AppLocalizations.of(context).pictureSent,
                style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontWeight: FontWeight.w500))
            : Text(AppLocalizations.of(context).takeApicture,
                style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget seeHowManyPeopleSeenItButtonV2({required String title, onPressed}) {
    return Flexible(
      child: AnimatedButton(
        onPressed: onPressed,
        shadowDegree: ShadowDegree.dark,
        color: const Color.fromARGB(255, 117, 15, 15),
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Text(
          AppLocalizations.of(context).changeTheChallengePlease,
          style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.white,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget seeWorldDashboardButtonV2({required String title, onPressed}) {
    return Flexible(
      child: AnimatedButton(
        onPressed: onPressed,
        shadowDegree: ShadowDegree.dark,
        color: const Color.fromARGB(255, 117, 15, 15),
        width: MediaQuery.of(context).size.width,
        child: Text(AppLocalizations.of(context).tenBestDisciple,
            style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.white,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  _notNowOnpressed() {
    pictureTaken = false;
    setState(() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    title: AppLocalizations.of(context).youAcceptedTicTac,
                    connectedUser: widget.connectedUser,
                  )));
    });
  }

  _takePictureOnPressed() async {
    final image = await getImage();
    setState(() {
      pictureFile = image;
      streak = streak++;
      pictureTaken = true;
    });
  }

  _sendProofOnPressed(BuildContext context) {
    if (pictureTaken) {
      EachDaysUtils.verboseIt("Sending proof for checking...");
      pictureSent = true;
      EvidenceUploaderService()
          .uploadEvidenceToFireBaseStorage(pictureFile, widget.connectedUser);
      pictureFile = null;

      setState(() {
        widget.connectedUser.didUserSendAPictureToday = "true";
      });
    } else {
      SnackBar snackbar = EachDaysUtils.ShowBlackSnackBar(
          AppLocalizations.of(context).whereIsThePictureGenius);
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

//TODO Modify this.
  seeHowManyPeopleSeenItPressed() {
    setState(() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    title: AppLocalizations.of(context).youAcceptedTicTac,
                    connectedUser: widget.connectedUser,
                  )));
    });
  }

//TODO Modify this.

  _seeWorldDashBoardPressed() {
    setState(() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    title: AppLocalizations.of(context).youAcceptedTicTac,
                    connectedUser: widget.connectedUser,
                  )));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text(AppLocalizations.of(context).proveIt),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
        ),
        body: Column(
          children: [
            processCameraPicture(context, pictureFile),
            const Expanded(
                child: Center(
              child: Text(''),
            )),
            SizedBox(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                okTakePictureV2(
                    title: AppLocalizations.of(context).proofButton,
                    onPressed: () => _takePictureOnPressed()),
                notNowButtonV2(
                    title: AppLocalizations.of(context).notNowChallenge,
                    onPressed: () => _notNowOnpressed()),
              ],
            )),
            SizedBox(
              child: Row(
                children: [
                  okSendProofButtonV2(
                      title: AppLocalizations.of(context).sendProofToTheDevil,
                      onPressed: () => _sendProofOnPressed(context)),
                ],
              ),
            ),
            SizedBox(
              child: Row(
                children: [
                  seeWorldDashboardButtonV2(
                    title: AppLocalizations.of(context).proofButton,
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                                title: Text(AppLocalizations.of(context)
                                    .tenBestDisciple),
                                content: _buildPopupDialog(
                                    context, widget.connectedUser));
                          });
                    },
                  )
                ],
              ),
            ),
            SizedBox(
              child: Row(
                children: [
                  seeHowManyPeopleSeenItButtonV2(
                      title: AppLocalizations.of(context).proofButton,
                      onPressed: () =>
                          EachDaysUtils.showEndingToast(false, context)),
                ],
              ),
            )
          ],
        ));
  }

  Future getImage() async {
    final image = await imagePicker.pickImage(source: ImageSource.camera);
    pictureFile = XFile(image!.path);
    return pictureFile;
  }
}

Widget processCameraPicture(BuildContext context, XFile? pictureFile) {
  if (pictureFile == null) {
    return Container(
      margin: const EdgeInsets.only(top: 20.0),
      height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.width,
      child: Image.asset("assets/splash/each_day_splash.png"),
    );
  }
  return Container(
    margin: const EdgeInsets.only(top: 20.0),
    child: Image.file(
      File(pictureFile.path),
      repeat: ImageRepeat.noRepeat,
      height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.width,
    ),
  );
}

Widget _buildPopupDialog(BuildContext context, lePacteUser connectedUser) {
  return SizedBox(
    height: MediaQuery.of(context).size.height *
        0.7, // Change as per your requirement
    width: MediaQuery.of(context).size.width *
        0.7, // Change as per your requirement
    child: ListView.builder(
        shrinkWrap: true,
        itemCount: _CameraPageState.topTenUsers.length,
        itemBuilder: (BuildContext context, int index) {
          return GFListTile(
              titleText: _CameraPageState.topTenUsers[index]['title'],
              avatar: Image.network(
                _CameraPageState.topTenUsers[index]['profilePicture'],
                height: 55,
              ),
              icon: const Icon(Icons.sports_score, color: Colors.red));
        }),
  );
}
