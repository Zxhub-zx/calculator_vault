import 'package:flutter/services.dart';

class InstalledApp {
  final String label;
  final String packageName;
  const InstalledApp({required this.label, required this.packageName});
  factory InstalledApp.fromMap(Map<dynamic, dynamic> m) =>
      InstalledApp(label: '${m['label']}', packageName: '${m['packageName']}');
}

class AppService {
  static const channel = MethodChannel('calculator_vault/apps');

  Future<List<InstalledApp>> apps() async {
    final raw = await channel.invokeMethod<List<dynamic>>('getLaunchableApps');
    return (raw ?? [])
        .map((e) => InstalledApp.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
  }

  Future<bool> launch(String packageName) async =>
      await channel.invokeMethod<bool>('launchApp', {'packageName': packageName}) ?? false;
}
