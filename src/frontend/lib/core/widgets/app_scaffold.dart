import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../localization/app_translations.dart';
import '../services/theme_controller.dart';
import '../utils/responsive.dart';
import 'voice_control_button.dart';

/// Shared scaffold for MediKiosk with responsive header, kiosk mode indicators,
/// theme mode switcher, Lucide icons, and adaptive content padding.
class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final String? roleBadge;
  final bool showThemeToggle;
  final bool showVoiceControl;
  final String? voiceContextHint;

  const AppScaffold({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.actions,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showBackButton = true,
    this.onBack,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.roleBadge,
    this.showThemeToggle = true,
    this.showVoiceControl = true,
    this.voiceContextHint,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTablet = Responsive.isTablet(context);
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: backgroundColor ?? (isDark ? AppColors.backgroundDark : AppColors.background),
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: (title != null || titleWidget != null || showBackButton)
          ? AppBar(
              toolbarHeight: isTablet ? 72.0 : 64.0,
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
              elevation: 0,
              scrolledUnderElevation: 1,
              shadowColor: Colors.black.withOpacity(0.08),
              leading: (showBackButton && canPop)
                  ? IconButton(
                      icon: Icon(
                        LucideIcons.arrow_left,
                        size: 22,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                      tooltip: tr('back'),
                      onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                    )
                  : null,
              title: titleWidget ??
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title ?? '',
                        style: (isTablet
                                ? AppTextStyles.headlineMedium
                                : AppTextStyles.headlineSmall)
                            .copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
              actions: [
                if (roleBadge != null)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF132F6E) : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      roleBadge!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark ? AppColors.highlight : AppColors.primaryNavy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (actions != null) ...actions!,
                if (showThemeToggle)
                  IconButton(
                    icon: Icon(
                      ThemeController.instance.isDarkMode ? LucideIcons.sun : LucideIcons.moon,
                      size: 20,
                    ),
                    onPressed: () => ThemeController.instance.toggleTheme(),
                  ),
              ],
            )
          : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Responsive.maxContentWidth,
            ),
            child: body,
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton ?? (showVoiceControl ? VoiceControlButton(
        extended: isTablet,
        contextHint: voiceContextHint ?? tr('voice_hint'),
      ) : null),
    );
  }
}

