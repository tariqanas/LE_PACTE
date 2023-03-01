import 'package:eachday/services/google_sign_in_provider.dart';
import 'package:eachday/signInScreen.dart';
import 'package:eachday/utils/eachdayutils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  NotificationSettings notificationSettings =
      await firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true);
  EachDaysUtils.verboseIt(
      'User granted permission: ${notificationSettings.authorizationStatus}');

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    EachDaysUtils.verboseIt(
        "Handling a background message: ${message.messageId}");
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        title: 'Le Pacte',
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('fr', ''),
          Locale('es', '')
        ],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: Colors.black,
            primarySwatch: Colors.red,
            fontFamily: 'Tapestry'),
        home: const SignInPage(),
      ));
}

  
//flutter run --no-sound-null-safety