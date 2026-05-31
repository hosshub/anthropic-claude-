import 'dart:math' as math;

import 'package:flutter/material.dart';

/// زر تسجيل الدخول الرسمي بحساب Google. يتبع إرشادات هوية Google:
/// خلفية بيضاء، حدود رقيقة، شعار G ملوّن، خط Roboto بحجم 14.
///
/// يستخدم `CustomPainter` لرسم شعار G بأربعة قطاعات ملوّنة بدلاً من
/// تحميل صورة، حتى لا نضيف أصلاً أو اعتماداً جديداً.
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final String label;

  const GoogleSignInButton({
    super.key,
    this.onPressed,
    this.loading = false,
    this.label = 'متابعة بحساب Google',
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null && !loading;
    return SizedBox(
      height: 50,
      child: Material(
        color: Colors.white,
        elevation: 0,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: loading ? null : onPressed,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFDADCE0), // Google's standard divider
                width: 1,
              ),
            ),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation(
                          Color(0xFF4285F4),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const GoogleGLogo(size: 20),
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style: TextStyle(
                            color: disabled
                                ? const Color(0xFF80868B)
                                : const Color(0xFF1F1F1F),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// شعار حرف G بألوان Google الأربعة، مرسوم بقطاعات مقوّسة دون أصول خارجية.
class GoogleGLogo extends StatelessWidget {
  final double size;
  const GoogleGLogo({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final stroke = s * 0.21;
    final center = Offset(s / 2, s / 2);
    final radius = (s - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // الزوايا في Canvas: 0 = يمين، π/2 = أسفل، π = يسار، -π/2 = أعلى.
    // نرسم أربعة أرباع حول الدائرة بترتيب Google القياسي.

    // أحمر: الربع الأيسر العلوي.
    ringPaint.color = _red;
    canvas.drawArc(rect, -math.pi, math.pi / 2, false, ringPaint);

    // أصفر: الربع الأيمن السفلي.
    ringPaint.color = _yellow;
    canvas.drawArc(rect, 0, math.pi / 2 - 0.18, false, ringPaint);

    // أخضر: الربع الأيسر السفلي.
    ringPaint.color = _green;
    canvas.drawArc(rect, math.pi / 2, math.pi / 2, false, ringPaint);

    // أزرق: الربع الأيمن العلوي.
    ringPaint.color = _blue;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi / 2,
      false,
      ringPaint,
    );

    // الذيل الأزرق الأفقي داخل حرف G.
    final barPaint = Paint()
      ..color = _blue
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(center.dx + radius + stroke / 2.4, center.dy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(_GoogleGPainter oldDelegate) => false;
}
