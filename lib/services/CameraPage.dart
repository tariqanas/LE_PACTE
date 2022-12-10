import 'package:camera/camera.dart';
import 'package:eachday/homescreen.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;

  const CameraPage({this.cameras, Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool pictureSent = false;
  bool pictureTaken = false;
  bool gotValidationFromAdmin = false;
  bool waitingForAdminAproval = false;
  int streak = 0;

  late CameraController controller;
  XFile? pictureFile;

  @override
  void initState() {
    super.initState();
    controller = CameraController(
      widget.cameras![1],
      ResolutionPreset.high,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget notNowButton({required String title, VoidCallback? onPressed}) {
    return Flexible(
      child: FloatingActionButton.extended(
        onPressed: (waitingForAdminAproval || pictureSent) ? null : onPressed,
        label: (waitingForAdminAproval || pictureSent)
            ? const Text('Le diable vérifieras..👹⏱️ ',style: TextStyle(color: Colors.black),)
            : const Text('Trop dûr pour moi..🐔'),
        backgroundColor:  Colors.red,
        heroTag: "waitButton",
      ),
    );
  }

  Widget okSendProofButton({required String title, VoidCallback? onPressed}) {
    return Expanded(
      child: FloatingActionButton.extended(
        onPressed: (waitingForAdminAproval || pictureSent || !pictureTaken) ? null : onPressed,
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

  Widget okTakePictureButton({required String title, VoidCallback? onPressed}) {
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
  seeHowManyPeopleSeenItButton(
      {required String title, VoidCallback? onPressed}) {
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
  seeWorldDashboardButton({required String title, VoidCallback? onPressed}) {
    return Expanded(
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        label: const Text('10 Meilleurs challengers du monde ! 🏆 ',style: TextStyle(color: Colors.black),),
        backgroundColor: Color.fromARGB(255, 255, 238, 0),
        heroTag: "okDashBoardButton",
      ),
    );
  }

  _notNowOnpressed() {
    controller.pausePreview();
    pictureTaken = false;
    setState(() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const HomeScreen(
                    title: 'You accepted..Tic..Tac ⏱️',
                    streak: 15,
                  )));
    });
  }

  _takePictureOnPressed() async {
    controller.resumePreview();
    pictureFile = await controller.takePicture();
    streak++;
    pictureTaken = true;
    setState(() {});
  }

  _sendProofOnPressed() {
    debugPrint("Sending proof for checking...");
    pictureSent = true;
    waitingForAdminAproval = true;
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
              builder: (context) => const HomeScreen(
                    title: 'You accepted..Tic..Tac ⏱️',
                    streak: 15,
                  )));
    });
  }

//TODO Modify this.

  _seeWorldDashBoardPressed() {
    setState(() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const HomeScreen(
                    title: 'You accepted..Tic..Tac ⏱️',
                    streak: 15,
                  )));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const SizedBox(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 0.4,
                child: CameraPreview(controller),
              ),
            ),
          ),
          if (pictureFile != null)
            SizedBox(
                child: Stack(
              children: [
                Image.network(pictureFile!.path,
                    height: 300, filterQuality: FilterQuality.medium)
              ],
            )),
          //Android/iOS
          // Image.file(File(pictureFile!.path)))
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              okTakePictureButton(
                  title: "proof", onPressed: () => _takePictureOnPressed()),
              notNowButton(
                  title: "notNow", onPressed: () => _notNowOnpressed()),
            ],
          ),
          Row(
            children: [
              okSendProofButton(
                  title: "proof", onPressed: () => _sendProofOnPressed()),
            ],
          ),
          Row(
            children: [
              seeHowManyPeopleSeenItButton(
                  title: "proof", onPressed: () => _sendProofOnPressed()),
            ],
          ),
          Row(
            children: [
              seeWorldDashboardButton(
                  title: "proof", onPressed: () => _seeWorldDashBoardPressed()),
            ],
          ),
        ],
      ),
    );
  }
}
