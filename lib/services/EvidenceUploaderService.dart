import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/eachdayutils.dart';

class EvidenceUploaderService {
  uploadEvidenceToFireBaseStorage(XFile? pictureTaken, User connectedUser,
      String challengeDescription) async {
    final _firebaseStorage = FirebaseStorage.instance;

    await Permission.camera.request();

    var permissionOnCameraStatus = await Permission.camera.status;

    if (permissionOnCameraStatus.isGranted) {
      File userProof = File(pictureTaken!.path);
      await _firebaseStorage
          .ref()
          .child(connectedUser.displayName! + '/' + challengeDescription)
          .putFile(userProof)
          .catchError((e) => EachDaysUtils.verboseIt(
              "Can't upload message for user" +
                  connectedUser.displayName.toString() +
                  "because of " +
                  e.toString()));
    }

    EachDaysUtils.verboseIt(connectedUser.displayName! +
        "took a picture" +
        "Description : " +
        challengeDescription);
  }
}
