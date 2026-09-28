import 'package:flutter/material.dart';
import '../services/security_service.dart';
import 'calculator_screen.dart';

class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({super.key});
  @override State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final pin = TextEditingController();
  final confirm = TextEditingController();
  String error = '';

  Future<void> save() async {
    if (pin.text.isEmpty) {
      setState(() => error = 'กรุณาตั้งรหัส');
      return;
    }
    if (pin.text != confirm.text) {
      setState(() => error = 'รหัสไม่ตรงกัน');
      return;
    }
    await SecurityService().setPin(pin.text);
    if (!mounted) return;
    Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (_) => const CalculatorScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(children: [
              const Icon(Icons.calculate_rounded, size: 80),
              const SizedBox(height: 24),
              const Text('ตั้งรหัสสำหรับเมนูหลัก',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('รหัสนี้ใช้เปิดพื้นที่ส่วนตัวของแอป'),
              const SizedBox(height: 28),
              TextField(
                controller: pin, obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'รหัส', border: OutlineInputBorder())),
              const SizedBox(height: 14),
              TextField(
                controller: confirm, obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ยืนยันรหัส', border: OutlineInputBorder())),
              if (error.isNotEmpty)
                Padding(padding: const EdgeInsets.only(top: 12),
                  child: Text(error, style: const TextStyle(color: Colors.redAccent))),
              const SizedBox(height: 22),
              SizedBox(width: double.infinity, height: 52,
                child: FilledButton(onPressed: save, child: const Text('ยืนยัน')))
            ]),
          ),
        ),
      ),
    );
  }
}
