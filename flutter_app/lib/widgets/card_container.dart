import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// بطاقة بيضاء بحواف ناعمة وظلّ خفيف (مثل CardContainer في SwiftUI).
class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;

  const CardContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: TColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
