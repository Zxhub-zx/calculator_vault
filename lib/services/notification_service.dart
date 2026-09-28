import 'package:flutter/services.dart';

class NotificationService {
  static const _channel = MethodChannel('calculator_vault/notifications');
  static Future<bool> isAccessEnabled() async => await _channel.invokeMethod<bool>('isNotificationAccessEnabled') ?? false;
  static Future<void> openAccessSettings() => _channel.invokeMethod('openNotificationAccessSettings');
  static Future<void> setHiddenPackages(List<String> packages) => _channel.invokeMethod('setHiddenPackages', {'packages': packages});
  static Future<void> clearHiddenPackage(String packageName) => _channel.invokeMethod('clearHiddenPackage', {'packageName': packageName});
}
