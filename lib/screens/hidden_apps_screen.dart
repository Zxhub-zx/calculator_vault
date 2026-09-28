import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_service.dart';
import '../services/notification_service.dart';

class HiddenAppsScreen extends StatefulWidget {
  const HiddenAppsScreen({super.key});
  @override State<HiddenAppsScreen> createState() => _HiddenAppsScreenState();
}

class _HiddenAppsScreenState extends State<HiddenAppsScreen> {
  final service = AppService();
  List<InstalledApp> apps = [];
  Set<String> selected = {};
  bool loading = true;
  bool notificationAccess = false;

  @override void initState() { super.initState(); load(); }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final saved = p.getStringList('vault_apps') ?? [];
    final list = await service.apps();
    final access = await NotificationService.isAccessEnabled();
    if (!mounted) return;
    setState(() { apps = list; selected = saved.toSet(); notificationAccess = access; loading = false; });
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('vault_apps', selected.toList());
    if (notificationAccess) await NotificationService.setHiddenPackages(selected.toList());
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('บันทึกแล้ว')));
  }

  Future<void> toggle(String pkg, bool value) async {
    setState(() => value ? selected.add(pkg) : selected.remove(pkg));
    if (notificationAccess) {
      if (value) await NotificationService.setHiddenPackages(selected.toList());
      else await NotificationService.clearHiddenPackage(pkg);
    }
  }

  Future<void> enableNotificationPrivacy() async {
    await NotificationService.openAccessSettings();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('เปิดสิทธิ์ Notification Access แล้วกลับมาหน้านี้ จากนั้นกดบันทึก')));
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แอปส่วนตัว'), actions: [
        IconButton(onPressed: save, icon: const Icon(Icons.save_rounded))
      ]),
      body: loading ? const Center(child: CircularProgressIndicator()) : Column(children: [
        Card(
          margin: const EdgeInsets.all(12),
          child: ListTile(
            leading: Icon(notificationAccess ? Icons.notifications_off_rounded : Icons.notifications_active_rounded),
            title: Text(notificationAccess ? 'โหมดความเป็นส่วนตัวของแจ้งเตือนเปิดอยู่' : 'ยังไม่ได้เปิดสิทธิ์แจ้งเตือน'),
            subtitle: Text(notificationAccess
                ? 'แอปที่เลือกจะถูกยกเลิกแจ้งเตือนขณะอยู่ในรายการซ่อน'
                : 'เปิดสิทธิ์นี้เพื่อให้แอปที่ซ่อนจัดการแจ้งเตือนได้'),
            trailing: notificationAccess ? const Icon(Icons.check_circle_rounded) : TextButton(
              onPressed: enableNotificationPrivacy, child: const Text('เปิดสิทธิ์')),
          ),
        ),
        Expanded(child: ListView.builder(
          itemCount: apps.length,
          itemBuilder: (_, i) {
            final a = apps[i];
            return CheckboxListTile(
              value: selected.contains(a.packageName),
              title: Text(a.label), subtitle: Text(a.packageName),
              onChanged: (v) => toggle(a.packageName, v == true),
              secondary: IconButton(icon: const Icon(Icons.open_in_new_rounded),
                onPressed: () => service.launch(a.packageName)),
            );
          },
        )),
      ]),
    );
  }
}
