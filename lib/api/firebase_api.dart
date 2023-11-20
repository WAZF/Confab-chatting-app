import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  final notification = message.notification;
  final data = message.data;

  if (notification != null) {
    final title = notification.title ?? '';
    final body = notification.body ?? '';

    final senderUid = data['senderUid'] ?? ''; // Assuming sender's UID is sent in the data payload
    final messageContent = data['message'] ?? ''; // Assuming message content is sent in the data payload

    print('Title: $title');
    print('Body: $body');

    // Now construct a notification with sender's UID and message content
    final notificationTitle = 'New message from $senderUid';
    final notificationBody = 'Message: $messageContent';

    // Show the constructed notification using your preferred method (e.g., using flutter_local_notifications package)
    // For example, with flutter_local_notifications package:
    // await showNotification(notificationTitle, notificationBody);
  }
}


class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}
