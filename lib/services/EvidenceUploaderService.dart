import 'dart:io';

import 'package:camera/camera.dart';
import 'package:eachday/model/lepacte_user.dart';
import 'package:eachday/services/handleFireBaseDB.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/eachdayutils.dart';

class EvidenceUploaderService {
  uploadEvidenceToFireBaseStorage(
      XFile? pictureTaken, lePacteUser connectedUser) async {
    final _firebaseStorage = FirebaseStorage.instance;
    final handleFireBaseDB handleDb = handleFireBaseDB();

    await Permission.camera.request();

    var permissionOnCameraStatus = await Permission.camera.status;

    if (permissionOnCameraStatus.isGranted) {
      File userProof = File(pictureTaken!.path);
      await _firebaseStorage
          .ref()
          .child(connectedUser.username + '/' + connectedUser.currentChallenge)
          .putFile(userProof)
          .then((picture) => {
                handleDb.sendProofToTheDevilOrEscape(connectedUser, true),
                EachDaysUtils.verboseIt(connectedUser.username +
                    "took a picture" +
                    "Description : " +
                    connectedUser.currentChallenge)
              })
          .catchError((e) => EachDaysUtils.verboseIt(
              "Can't upload message for user " +
                  connectedUser.username.toString() +
                  " because of " +
                  e.toString()));
    } else {
      EachDaysUtils.verboseIt("User had no Camera persmission !! ");
    }
  }
}
