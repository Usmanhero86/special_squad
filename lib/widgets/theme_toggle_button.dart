import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return PopupMenuButton<ThemeMode>(
          icon: Icon(
            themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          ),
          tooltip: 'Change Theme',
          onSelected: (ThemeMode mode) {
            themeService.setThemeMode(mode);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: ThemeMode.system,
              child: Row(
                children: [
                  const Icon(Icons.brightness_auto),
                  const SizedBox(width: 8),
                  const Text('System'),
                  if (themeService.themeMode == ThemeMode.system)
                    const Spacer(),
                  if (themeService.themeMode == ThemeMode.system)
                    const Icon(Icons.check, color: Colors.blue),
                ],
              ),
            ),
            PopupMenuItem(
              value: ThemeMode.light,
              child: Row(
                children: [
                  const Icon(Icons.light_mode),
                  const SizedBox(width: 8),
                  const Text('Light'),
                  if (themeService.themeMode == ThemeMode.light) const Spacer(),
                  if (themeService.themeMode == ThemeMode.light)
                    const Icon(Icons.check, color: Colors.blue),
                ],
              ),
            ),
            PopupMenuItem(
              value: ThemeMode.dark,
              child: Row(
                children: [
                  const Icon(Icons.dark_mode),
                  const SizedBox(width: 8),
                  const Text('Dark'),
                  if (themeService.themeMode == ThemeMode.dark) const Spacer(),
                  if (themeService.themeMode == ThemeMode.dark)
                    const Icon(Icons.check, color: Colors.blue),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
