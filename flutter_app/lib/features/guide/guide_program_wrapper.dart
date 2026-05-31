import 'package:flutter/material.dart';

import '../program/program_screen.dart';

/// ٠٦ — يلفّ ProgramScreen الفعلي حتى يبقى رابط الفهرس ثابتاً.
class GuideProgramWrapper extends StatelessWidget {
  const GuideProgramWrapper({super.key});

  @override
  Widget build(BuildContext context) => const ProgramScreen();
}
