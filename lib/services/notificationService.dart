import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import '../utils/eachdayutils.dart';

class NotificationService {
  NotificationService();

  final _notifications = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String> behaviorSubject = BehaviorSubject();

  Future<void> initializePlatformNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('each_day_splash');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(initializationSettings,
        onDidReceiveNotificationResponse : selectNotification,
        onDidReceiveBackgroundNotificationResponse: selectNotification);
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
     EachDaysUtils.verboseIt("ID Notification $id");
  }

  void selectNotification(NotificationResponse notificationResponse) async {
    if (notificationResponse.payload != null && notificationResponse.payload!.isNotEmpty) {
      behaviorSubject.add(notificationResponse.payload!);
    } 

  }

  Future<NotificationDetails> _notificationDetails() async {
    
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      const AndroidNotificationDetails(
    'channel id',
    'channel name',
    groupKey: 'com.example.flutter_push_notifications',
    channelDescription: 'channel description',
    importance: Importance.max,
    priority: Priority.max,
    playSound: true,
    ticker: 'ticker',
    largeIcon: DrawableResourceAndroidBitmap('each_day_splash'),
    color: Color(0xff2196f3),
  );

  DarwinNotificationDetails iosNotificationDetails = const DarwinNotificationDetails(
      threadIdentifier: "thread1",
      attachments: <DarwinNotificationAttachment>[
        DarwinNotificationAttachment("bigPicture")
      ]);

  final details = await _notifications.getNotificationAppLaunchDetails();
  if (details != null && details.didNotificationLaunchApp) {
    behaviorSubject.add(details.notificationResponse!.payload!);
  }
  NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iosNotificationDetails);

  return platformChannelSpecifics;
}

Future<void> showLocalNotification({
  required int id,
  required String title,
  required String body,
  required String payload,
}) async {
  final platformChannelSpecifics = await _notificationDetails();
  await _notifications.show(
    id,
    title,
    body,
    platformChannelSpecifics,
    payload: payload,
  );
}

}
