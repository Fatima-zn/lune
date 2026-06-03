import 'package:flutter_background_service/flutter_background_service.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
      autoStartOnBoot: false,
      notificationChannelId: 'my_channel',
      initialNotificationTitle: 'Podcast Player',
      initialNotificationContent: 'Ready to play',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  service.on('updateNotification').listen((event) async {
    final data = event;
    final title = data?['title'] as String? ?? '';
    final podcastTitle = data?['podcastTitle'] as String? ?? '';
    final isPlaying = data?['isPlaying'] as bool? ?? false;

    if (service is AndroidServiceInstance) {
      final content = podcastTitle.isNotEmpty ? podcastTitle : '';
      final statusText = isPlaying ? 'Now Playing' : 'Paused';
      final fullContent = '$statusText${content.isNotEmpty ? ' • $content' : ''}';

      service.setForegroundNotificationInfo(
        title: title.isNotEmpty ? title : 'Podcast Player',
        content: fullContent,
      );
    }
  });
}