import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Selectable option card designed for AYUSH health & Prakriti assessment screens.
/// Features high contrast, large 48px+ touch area, radio/checkbox indicator, and optional dosha badge.
class OptionCard extends StatelessWidget {
  final String title;
  final String? description;
  final bool isSelected;
  final VoidCallback onSelect;
  final IconData? icon;
  final String? badgeText;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final bool isMultiSelect;
  final EdgeInsetsGeometry padding;

  const OptionCard({
    super.key,
    required this.title,
    this.description,
    required this.isSelected,
    required this.onSelect,
    this.icon,
    this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
    this.isMultiSelect = false,
    this.padding = const EdgeInsets.all(18.0),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color borderColor = isSelected 
        ? AppColors.primary 
        : (isDark ? AppColors.borderDark : AppColors.border);

    final Color bgColor = isSelected 
        ? (isDark ? const Color(0xFF152A56) : AppColors.surfaceVariant.withOpacity(0.6))
        : (isDark ? AppColors.surfaceDark : AppColors.surfaceElevated);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.12),
              offset: const Offset(0, 3),
              blurRadius: 10,
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
              offset: const Offset(0, 1),
              blurRadius: 4,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onSelect,
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
          child: Padding(
            padding: padding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Selection Indicator (Radio or Checkbox style)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: isMultiSelect ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: isMultiSelect ? BorderRadius.circular(6) : null,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : (isDark ? AppColors.textMutedDark : AppColors.textMuted),
                      width: 2.0,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          LucideIcons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 14),

                // Optional Icon
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? (isDark ? const Color(0xFF1D3E7F) : AppColors.primaryContainer) 
                          : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isSelected 
                          ? (isDark ? AppColors.highlight : AppColors.primary) 
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],

                // Content (Title & Description)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: isDark
                                ? (isSelected ? AppColors.textPrimaryDark : AppColors.textPrimaryDark)
                                : (isSelected ? AppColors.primaryNavy : AppColors.textPrimary),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor ?? (isDark ? const Color(0xFF0F322B) : AppColors.secondaryContainer),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeText!,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: badgeTextColor ?? (isDark ? AppColors.highlight : AppColors.secondary),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
