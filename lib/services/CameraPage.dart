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
        onPressed: onPressed,
        label: const Text('Trop dûr pour moi..🐔'),
        backgroundColor: Colors.red,
        heroTag: "waitButton",
      ),
    );
  }

  Widget okSendProofButton({required String title, VoidCallback? onPressed}) {
    return Flexible(
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        label: const Text('Envoyer la preuve au diable ! 👹 '),
        backgroundColor: Colors.red,
        heroTag: "okSendProofButton",
      ),
    );
  }

  Widget okTakePictureButton({required String title, VoidCallback? onPressed}) {
    return Flexible(
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        label: const Text('Prendre une photo ! 👹 '),
        backgroundColor: Colors.red,
        heroTag: "okCaptureProofButton",
      ),
    );
  }

  _notNowOnpressed() {
    controller.pausePreview();
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
    setState(() {
      streak++;
    });
  }

  _sendProofOnPressed() {
    debugPrint("Sending proof for checking...");
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
            children: <Widget> [
              okSendProofButton(
                  title: "proof", onPressed: () => _sendProofOnPressed()),
            ],
          )
        ],
      ),
    );
  }
}
