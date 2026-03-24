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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.west_rounded, color: AppTheme.textDark),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Settings',
          style: theme.textTheme.labelLarge?.copyWith(
            letterSpacing: 1.5,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Theme Section
            Row(
              children: [
                Text(
                  'Theme',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 16),
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

            const SizedBox(height: 48),
            const _SectionHeader(title: 'Alerts'),
            _SettingToggleRow(
              label: 'Notifications',
              value: settings.enableNotifications,
              onChanged: controller.updateNotifications,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'System Permissions',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textDark.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _openNotificationSettings(context);
                  },
                  child: const Text(
                    'Configure',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),
            const _SectionHeader(title: 'Pomodoro'),
            _SettingToggleRow(
              label: 'Auto-start next timer',
              value: !settings.confirmBeforeNextTimer,
              onChanged: (val) => controller.updateConfirmation(!val),
            ),
            const SizedBox(height: 24),
            _SettingToggleRow(
              label: 'Sound on completion',
              value: settings.playSoundWhenCompleted,
              onChanged: controller.updateSound,
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reset all timers',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textDark.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    controller.resetPomodoroSettings();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.textDark.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 80),
            Center(
              child: Opacity(
                opacity: 0.3,
                child: Text(
                  'Pom v1.0.0',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.textDark.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
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
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textDark.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
              fontSize: 16,
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
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(!value);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: value ? AppTheme.textDark : AppTheme.textDark.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? AppTheme.textLight : AppTheme.textDark.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
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
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.textDark : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppTheme.textDark : AppTheme.textDark.withValues(alpha: 0.1),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : AppTheme.textDark.withValues(alpha: 0.6),
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
