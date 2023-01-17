import 'dart:io';

import 'package:camera/camera.dart';
import 'package:eachday/model/lepacte_user.dart';
import 'package:eachday/services/handleFireBaseDB.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/eachdayutils.dart';

class EvidenceUploaderService {
  uploadEvidenceToFireBaseStorage(XFile? pictureTaken, lePacteUser connectedUser,
      String challengeDescription) async {
    final _firebaseStorage = FirebaseStorage.instance;
    final handleFireBaseDB handleDb = handleFireBaseDB();

    await Permission.camera.request();

    var permissionOnCameraStatus = await Permission.camera.status;

    if (permissionOnCameraStatus.isGranted) {
      File userProof = File(pictureTaken!.path);
      await _firebaseStorage
          .ref()
          .child(connectedUser.username + '/' + challengeDescription)
          .putFile(userProof).then((p0) => {

            // Fix bug  here. (50% compare between username and displayname) 
            // Update DB last SavedDate, (Call here to saveDecision not there. 
            // We're not sure it's going to work)
            // Boolean SendPicture.
            // Update booleans to prevent resending.
            // Add a ticket maybe .. to see if he can't still log to do stuff.
          })
          .catchError((e) => EachDaysUtils.verboseIt(
              "Can't upload message for user" +
                  connectedUser.username.toString() +
                  "because of " +
                  e.toString()));
    }

    EachDaysUtils.verboseIt(connectedUser.username +
        "took a picture" +
        "Description : " +
        challengeDescription);
  }
}
