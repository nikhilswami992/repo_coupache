import 'package:flutter/services.dart';

class AppDetectionService {
  static const _channel =
      MethodChannel('foreground_app_channel');

  static void startListening(
      void Function(String packageName) onAppChanged,
  ) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onAppChanged') {
        final packageName = call.arguments as String;
        onAppChanged(packageName);
      }
    });
  }
}