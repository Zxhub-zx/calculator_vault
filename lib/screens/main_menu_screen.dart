import 'package:flutter/material.dart';
import 'hidden_apps_screen.dart';
import 'calculator_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('เมนูหลัก')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Card(child: Padding(padding: EdgeInsets.all(22), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('พื้นที่ส่วนตัว', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          SizedBox(height: 6), Text('เลือกแอปที่ต้องการเก็บไว้ในรายการส่วนตัว และตั้งค่าความเป็นส่วนตัวของแจ้งเตือน')]))),
      const SizedBox(height: 10),
      ListTile(leading: const Icon(Icons.apps_rounded), title: const Text('จัดการแอปที่ซ่อน'),
        subtitle: const Text('เลือกแอปและตั้งค่าการแจ้งเตือน'),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HiddenAppsScreen()))),
      ListTile(leading: const Icon(Icons.calculate_rounded), title: const Text('กลับเครื่องคิดเลข'),
        onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CalculatorScreen()), (_) => false)),
    ]),
  );
}
