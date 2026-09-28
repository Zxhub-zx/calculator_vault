import 'package:flutter/material.dart';
import '../services/calculator_service.dart';
import '../services/security_service.dart';
import 'main_menu_screen.dart';
import 'hidden_apps_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String expression = '';
  String display = '0';
  int equalsCount = 0;
  String lastSecretCandidate = '';

  /// รหัสล้วน หรือ รหัสตามด้วยจุด เช่น 1234 หรือ 1234.
  bool _isSecretCandidate(String value) {
    return RegExp(r'^\d+\.?$').hasMatch(value) && value.isNotEmpty && value != '.';
  }

  Future<void> _equals() async {
    if (expression.isEmpty) return;

    final candidate = expression;

    // --- โหมดรหัสลับ: นับการกด = ติดกันบนรหัสเดิม ---
    if (_isSecretCandidate(candidate)) {
      if (candidate == lastSecretCandidate) {
        equalsCount++;
      } else {
        equalsCount = 1;
        lastSecretCandidate = candidate;
      }

      // กด = ครบ 3 ครั้ง → ตรวจรหัส
      if (equalsCount >= 3) {
        final isMain = candidate.endsWith('.');
        final pin = isMain ? candidate.substring(0, candidate.length - 1) : candidate;

        if (pin.isNotEmpty && await SecurityService().verifyPin(pin)) {
          if (!mounted) return;
          setState(() {
            expression = '';
            display = '0';
            equalsCount = 0;
            lastSecretCandidate = '';
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  isMain ? const MainMenuScreen() : const HiddenAppsScreen(),
            ),
          );
          return;
        } else {
          // รหัสผิด
          equalsCount = 0;
          lastSecretCandidate = '';
        }
      }

      // ยังไม่ครบ 3 ครั้ง หรือรหัสผิด → แสดงค่าเดิม ไม่คำนวณทับ
      setState(() {
        display = candidate;
      });
      return;
    }

    // --- โหมดเครื่องคิดเลขปกติ ---
    equalsCount = 0;
    lastSecretCandidate = '';
    final result = CalculatorService.evaluate(expression);
    if (result != 'Error') {
      setState(() {
        display = result;
        expression = result;
      });
    } else {
      setState(() => display = 'Error');
    }
  }

  void _tap(String k) {
    if (k == '=') {
      _equals();
      return;
    }

    setState(() {
      // กดปุ่มอื่น → รีเซ็ตการนับรหัสลับ
      equalsCount = 0;
      lastSecretCandidate = '';

      if (k == 'AC') {
        expression = '';
        display = '0';
        return;
      }
      if (k == 'DEL') {
        if (expression.isNotEmpty) {
          expression = expression.substring(0, expression.length - 1);
        }
        display = expression.isEmpty ? '0' : expression;
        return;
      }
      if (k == '%') {
        final m = RegExp(r'(\d+(?:\.\d+)?)$').firstMatch(expression);
        if (m != null) {
          final value = double.parse(m.group(1)!) / 100;
          expression = expression.substring(0, m.start) + _format(value);
          display = expression;
        }
        return;
      }
      if (k == '.') {
        if (expression.isEmpty || _endsOp()) {
          expression += '0.';
        } else if (!_currentNumberHasDot()) {
          expression += '.';
        }
        display = expression;
        return;
      }
      if ('+-×÷'.contains(k)) {
        if (expression.isNotEmpty && !_endsOp()) expression += k;
        display = expression.isEmpty ? '0' : expression;
        return;
      }
      expression += k;
      display = expression;
    });
  }

  bool _endsOp() =>
      expression.isNotEmpty && '+-×÷'.contains(expression[expression.length - 1]);

  bool _currentNumberHasDot() {
    for (int i = expression.length - 1; i >= 0; i--) {
      if ('+-×÷'.contains(expression[i])) return false;
      if (expression[i] == '.') return true;
    }
    return false;
  }

  String _format(double x) => x == x.roundToDouble()
      ? x.toInt().toString()
      : x
          .toStringAsFixed(10)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');

  Widget key(String label, {bool accent = false, bool zero = false}) => Expanded(
        flex: zero ? 2 : 1,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Material(
            color: accent ? const Color(0xFF303030) : const Color(0xFF1B1B1B),
            borderRadius: BorderRadius.circular(50),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () => _tap(label),
              child: SizedBox(
                height: 72,
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF050505),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      display,
                      style: const TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ),
              Row(children: [key('AC'), key('DEL'), key('%'), key('÷', accent: true)]),
              Row(children: [key('7'), key('8'), key('9'), key('×', accent: true)]),
              Row(children: [key('4'), key('5'), key('6'), key('-', accent: true)]),
              Row(children: [key('1'), key('2'), key('3'), key('+', accent: true)]),
              Row(children: [key('0', zero: true), key('.'), key('=', accent: true)]),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
}
