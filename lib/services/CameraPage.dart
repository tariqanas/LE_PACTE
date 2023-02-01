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
        child: (widget.connectedUser.didUserSendAPictureToday == "true" ||
                widget.connectedUser.refusedChallengeToday == "true")
            ? const Text(
                'Le diable vérifieras..👹⏱️ ',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              )
            : const Text('Pas tout de suite..🐔',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
        onPressed: onPressed,
        enabled: (widget.connectedUser.didUserSendAPictureToday == "false" &&
            widget.connectedUser.refusedChallengeToday == "false"),
        shadowDegree: ShadowDegree.dark,
        color: const Color.fromARGB(255, 117, 15, 15),
        height: 50,
      ),
    );
  }

  Widget okSendProofButtonV2({required String title, onPressed}) {
    return Flexible(
      child: AnimatedButton(
        child: (widget.connectedUser.didUserSendAPictureToday == "true" ||
                widget.connectedUser.refusedChallengeToday == "true")
            ? const Text('En attente de validation ⏱️',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black,
                    fontWeight: FontWeight.w500))
            : const Text('Envoyer la preuve au diable ! 👹 ',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
        enabled: (widget.connectedUser.didUserSendAPictureToday == "false" &&
            widget.connectedUser.refusedChallengeToday == "false"),
        onPressed: onPressed,
        shadowDegree: ShadowDegree.dark,
        color: const Color.fromARGB(255, 117, 15, 15),
        height: 50,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }

  Widget okTakePictureV2({required String title, onPressed}) {
    return Flexible(
      child: AnimatedButton(
        child: (widget.connectedUser.didUserSendAPictureToday == "true" ||
                widget.connectedUser.refusedChallengeToday == "true")
            ? const Text('Photo envoyée  ! 👹✔️',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontWeight: FontWeight.w500))
            : const Text('Prendre une photo 👹📷 ',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
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
      ),
    );
  }

  Widget seeHowManyPeopleSeenItButtonV2({required String title, onPressed}) {
    return Flexible(
      child: AnimatedButton(
        child: const Text(
          'Statistique des autres ! ⚔️ ',
          style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.white,
              fontWeight: FontWeight.w500),
        ),
        onPressed: onPressed,
        shadowDegree: ShadowDegree.dark,
        color: const Color.fromARGB(255, 117, 15, 15),
        height: 50,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }

  Widget seeWorldDashboardButtonV2({required String title, onPressed}) {
    return Flexible(
      child: AnimatedButton(
        child: const Text('10 Meilleurs challengers du monde ! 🏆 ',
            style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.white,
                fontWeight: FontWeight.w500)),
        onPressed: onPressed,
        shadowDegree: ShadowDegree.dark,
        color: const Color.fromARGB(255, 117, 15, 15),
        width: MediaQuery.of(context).size.width,
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
                    title: 'You accepted..Tic..Tac ⏱️',
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

  _sendProofOnPressed() {
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
      EachDaysUtils.takeaPictureFirst();
    }
  }

//TODO Modify this.
  seeHowManyPeopleSeenItPressed() {
    setState(() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    title: 'You accepted..Tic..Tac ⏱️',
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
                    title: 'You accepted..Tic..Tac ⏱️',
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
          title: const Text('Prouves-le : 👹🧾 '),
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
                    title: "proof", onPressed: () => _takePictureOnPressed()),
                notNowButtonV2(
                    title: "notNow", onPressed: () => _notNowOnpressed()),
              ],
            )),
            SizedBox(
              child: Row(
                children: [
                  okSendProofButtonV2(
                      title: "sendProof",
                      onPressed: () => _sendProofOnPressed()),
                ],
              ),
            ),
            SizedBox(
              child: Row(
                children: [
                  seeHowManyPeopleSeenItButtonV2(
                      title: "proof",
                      onPressed: () => EachDaysUtils.showEndingToast(false)),
                ],
              ),
            ),
            SizedBox(
              child: Row(
                children: [
                  seeWorldDashboardButtonV2(
                    title: "proof",
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                                title: const Text('10 Meilleurs démons 👹🏆 '),
                                content: _buildPopupDialog(
                                    context, widget.connectedUser));
                          });
                    },
                  )
                ],
              ),
            ),
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
      child: Image.asset("assets/splash/each_day_splash.png"),
      height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.width,
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
              avatar: Image.network(_CameraPageState.topTenUsers[index]['profilePicture'], height: 55,),
              icon: const Icon(Icons.favorite, color: Colors.red));
        }),
  );
}
