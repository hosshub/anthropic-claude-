import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Shared placeholder for scaffolded-but-not-yet-built tabs. Each references
/// the PRD epic it will implement so the build path is obvious.
class PlaceholderScaffold extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;
  const PlaceholderScaffold({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: WColors.primary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: WColors.textSecondary, height: 1.6)),
            ],
          ),
        ),
      ),
    );
  }
}
