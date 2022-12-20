// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAEMCDr1JKoL1aqmAMOIyVvHxIv3xh3cqg',
    appId: '1:1043013430227:web:84139499393bbf9851dd26',
    messagingSenderId: '1043013430227',
    projectId: 'le-pacte',
    authDomain: 'le-pacte.firebaseapp.com',
    storageBucket: 'le-pacte.appspot.com',
    measurementId: 'G-N78KXJ9XSP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD6UMJ48XTVRcklr30L8oVPG4f6MCD4ud4',
    appId: '1:1043013430227:android:5ec3c9d081096aed51dd26',
    messagingSenderId: '1043013430227',
    projectId: 'le-pacte',
    storageBucket: 'le-pacte.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDSu87MBZdKaYIHQMIZw7WOBdsr8E31l24',
    appId: '1:1043013430227:ios:f9be2a0c933cb60851dd26',
    messagingSenderId: '1043013430227',
    projectId: 'le-pacte',
    storageBucket: 'le-pacte.appspot.com',
    iosClientId: '1043013430227-nvbs0u0rps49f16bltht97vnms142r4i.apps.googleusercontent.com',
    iosBundleId: 'com.example.eachday',
  );
}
