import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../application/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _openNotificationSettings(BuildContext context) async {
    final plugin = FlutterLocalNotificationsPlugin();
    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      final areEnabled = await androidPlugin.areNotificationsEnabled() ?? false;
      if (areEnabled) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifications are already enabled'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
      await androidPlugin.requestNotificationsPermission();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            const Icon(Icons.timer, color: AppTheme.textDark, size: 28),
            const SizedBox(width: 8),
            Text(
              'Pom'.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.textDark,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: AppTheme.textDark, thickness: 0.5),
            const SizedBox(height: 16),

            // Theme Section
            Row(
              children: [
                const Text(
                  'Theme:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _ThemePill(
                          label: 'Green',
                          color: AppTheme.green,
                          isSelected: settings.themeColor == 'Green',
                          onTap: () => controller.updateThemeColor('Green'),
                        ),
                        _ThemePill(
                          label: 'Yellow',
                          color: AppTheme.yellow,
                          isSelected: settings.themeColor == 'Yellow',
                          onTap: () => controller.updateThemeColor('Yellow'),
                        ),
                        _ThemePill(
                          label: 'Red',
                          color: AppTheme.red,
                          isSelected: settings.themeColor == 'Red',
                          onTap: () => controller.updateThemeColor('Red'),
                        ),
                        _ThemePill(
                          label: 'Violet',
                          color: AppTheme.violet,
                          isSelected: settings.themeColor == 'Violet',
                          onTap: () => controller.updateThemeColor('Violet'),
                        ),
                        _ThemePill(
                          label: 'Blue',
                          color: AppTheme.blue,
                          isSelected: settings.themeColor == 'Blue',
                          onTap: () => controller.updateThemeColor('Blue'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            const _SectionHeader(title: 'Alerts'),
            _SettingToggleRow(
              label: 'Enable notifications:',
              value: settings.enableNotifications,
              onChanged: controller.updateNotifications,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'System notification permission:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _openNotificationSettings(context);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.textDark),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Open',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            const _SectionHeader(title: 'Pomodoro'),
            _SettingToggleRow(
              label: 'Confirm before starting next timer:',
              value: settings.confirmBeforeNextTimer,
              onChanged: controller.updateConfirmation,
            ),
            const SizedBox(height: 24),
            _SettingToggleRow(
              label: 'Play sound when completed:',
              value: settings.playSoundWhenCompleted,
              onChanged: controller.updateSound,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reset timers:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    controller.resetPomodoroSettings();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.textDark),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),
            Center(
              child: const Text(
                'Pom v1.0.0',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const Divider(color: AppTheme.textDark, thickness: 0.5),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SettingToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
        ),
        _TogglePill(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _TogglePill extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _TogglePill({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.textDark),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleSide(
            label: 'Yes',
            isSelected: value,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(20),
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              onChanged(true);
            },
          ),
          _ToggleSide(
            label: 'No',
            isSelected: !value,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(20),
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              onChanged(false);
            },
          ),
        ],
      ),
    );
  }
}

class _ToggleSide extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _ToggleSide({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
        constraints: const BoxConstraints(minWidth: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.charcoalDark : Colors.transparent,
          borderRadius: borderRadius,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.textLight : AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ThemePill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _ThemePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.charcoalDark : Colors.transparent,
            border: isSelected ? null : Border.all(color: AppTheme.textDark),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : AppTheme.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
