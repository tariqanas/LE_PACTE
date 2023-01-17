import 'dart:io';

import 'package:camera/camera.dart';
import 'package:eachday/homescreen.dart';
import 'package:eachday/model/lepacte_user.dart';
import 'package:eachday/services/EvidenceUploaderService.dart';
import 'package:eachday/services/handleFireBaseDB.dart';
import 'package:eachday/utils/eachdayutils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  EvidenceUploaderService evidence = EvidenceUploaderService();

  handleFireBaseDB handleDB = handleFireBaseDB();

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget notNowButton({required String title, onPressed}) {
    return Flexible(
      child: FloatingActionButton.extended(
        onPressed: (waitingForAdminAproval || pictureSent) ? null : onPressed,
        label: (waitingForAdminAproval || pictureSent)
            ? const Text(
                'Le diable vérifieras..👹⏱️ ',
                style: TextStyle(color: Colors.black),
              )
            : const Text('Pas tout de suite..🐔'),
        backgroundColor: Colors.red,
        heroTag: "waitButton",
      ),
    );
  }

  Widget okSendProofButton({required String title, onPressed}) {
    return Expanded(
      child: FloatingActionButton.extended(
        onPressed: (waitingForAdminAproval || pictureSent || !pictureTaken)
            ? null
            : onPressed,
        label: (waitingForAdminAproval || pictureSent)
            ? const Text('En attente de validation ⏱️')
            : const Text('Envoyer la preuve au diable ! 👹 '),
        backgroundColor: (waitingForAdminAproval || pictureSent)
            ? Colors.grey
            : Colors.green,
        heroTag: "okSendProofButton",
      ),
    );
  }

  Widget okTakePictureButton({required String title, onPressed}) {
    return Flexible(
      child: FloatingActionButton.extended(
        onPressed: (waitingForAdminAproval || pictureSent) ? null : onPressed,
        label: (waitingForAdminAproval || pictureSent)
            ? const Text('Photo envoyée  ! 👹✔️')
            : const Text('Prendre une photo 👹📷 '),
        backgroundColor:
            (waitingForAdminAproval || pictureSent) ? Colors.grey : Colors.red,
        heroTag: "okCaptureProofButton",
      ),
    );
  }

//TODO Modify this.
  seeHowManyPeopleSeenItButton({required String title, onPressed}) {
    return Expanded(
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        label: const Text('Statistique des autres ! ⚔️ '),
        backgroundColor: Colors.blue,
        heroTag: "okOtherPeopleButton",
      ),
    );
  }

//TODO Modify this.
  seeWorldDashboardButton({required String title, onPressed}) {
    return Expanded(
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        label: const Text(
          '10 Meilleurs challengers du monde ! 🏆 ',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color.fromARGB(255, 255, 238, 0),
        heroTag: "okDashBoardButton",
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
    EachDaysUtils.verboseIt("Sending proof for checking...");
    pictureSent = true;
    waitingForAdminAproval = true;
    EvidenceUploaderService().uploadEvidenceToFireBaseStorage(
        pictureFile, widget.connectedUser, widget.connectedUser.currentChallenge);
    pictureFile = XFile("");

    handleDB.sendProofToTheDevilOrEscape(widget.connectedUser, pictureSent);
    setState(() {});

    //Handle validation.(DB)
    // Wait for approval to increase streak.
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
                okTakePictureButton(
                    title: "proof", onPressed: () => _takePictureOnPressed()),
                notNowButton(
                    title: "notNow", onPressed: () => _notNowOnpressed()),
              ],
            )),
            SizedBox(
              child: Row(
                children: [
                  okSendProofButton(
                      title: "proof", onPressed: () => _sendProofOnPressed()),
                ],
              ),
            ),
            SizedBox(
              child: Row(
                children: [
                  seeHowManyPeopleSeenItButton(
                      title: "proof",
                      onPressed: () => EachDaysUtils.showEndingToast(false)),
                ],
              ),
            ),
            SizedBox(
              child: Row(
                children: [
                  seeWorldDashboardButton(
                      title: "proof",
                      onPressed: () =>
                          EachDaysUtils.verboseIt("See Champions !!!!")),
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
  debugPrint("Not null");
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
