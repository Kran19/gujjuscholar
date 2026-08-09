import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class ScreenProtector {
  static const _channel = MethodChannel('com.example.edustream/screen_protection');

  static Future<void> protect() async {
    try {
      await _channel.invokeMethod('protectScreen');
    } catch (e) {
      debugPrint("Screen Protection Error: $e");
    }
  }

  static Future<void> clear() async {
    try {
      await _channel.invokeMethod('clearScreen');
    } catch (e) {
      debugPrint("Screen Protection Clear Error: $e");
    }
  }
}
