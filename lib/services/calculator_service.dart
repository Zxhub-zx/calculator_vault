class CalculatorService {
  static String evaluate(String expression) {
    try {
      final s = expression.replaceAll('×', '*').replaceAll('÷', '/');
      final tokens = _tokens(s);
      if (tokens.isEmpty) return '0';
      final nums = <double>[];
      final ops = <String>[];
      int prec(String op) => (op == '+' || op == '-') ? 1 : 2;
      void apply() {
        if (nums.length < 2 || ops.isEmpty) throw Exception();
        final b = nums.removeLast(), a = nums.removeLast(), op = ops.removeLast();
        final r = switch (op) { '+' => a + b, '-' => a - b, '*' => a * b, '/' => b == 0 ? double.nan : a / b, _ => double.nan };
        if (r.isNaN || r.isInfinite) throw Exception();
        nums.add(r);
      }
      for (final t in tokens) {
        final n = double.tryParse(t);
        if (n != null) nums.add(n);
        else { while (ops.isNotEmpty && prec(ops.last) >= prec(t)) apply(); ops.add(t); }
      }
      while (ops.isNotEmpty) apply();
      if (nums.length != 1) return 'Error';
      return _format(nums.single);
    } catch (_) { return 'Error'; }
  }
  static List<String> _tokens(String s) {
    final out = <String>[]; final b = StringBuffer();
    for (final c in s.split('')) {
      if ('0123456789.'.contains(c)) b.write(c);
      else if ('+-*/'.contains(c)) { if (b.isNotEmpty) { out.add(b.toString()); b.clear(); } out.add(c); }
    }
    if (b.isNotEmpty) out.add(b.toString());
    return out;
  }
  static String _format(double x) => x == x.roundToDouble()
      ? x.toInt().toString()
      : x.toStringAsFixed(10).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}
