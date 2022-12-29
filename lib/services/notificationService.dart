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

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
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
        onSelectNotification: selectNotification);
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
     EachDaysUtils.verboseIt("IIIIID" + id.toString());
  }

  void selectNotification(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      behaviorSubject.add(payload);
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

  IOSNotificationDetails iosNotificationDetails = const IOSNotificationDetails(
      threadIdentifier: "thread1",
      attachments: <IOSNotificationAttachment>[
        IOSNotificationAttachment("bigPicture")
      ]);

  final details = await _notifications.getNotificationAppLaunchDetails();
  if (details != null && details.didNotificationLaunchApp) {
    behaviorSubject.add(details.payload!);
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
