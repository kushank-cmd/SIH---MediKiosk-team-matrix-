import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

enum ButtonVariant { primary, secondary, outline, danger }

/// Reusable high-contrast action button designed with large touch targets (min 52px height)
/// for comfortable kiosk tablet and phone interactions.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final ButtonVariant variant;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.variant = ButtonVariant.primary,
    this.width,
    this.height = 54.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;

    Color getBgColor() {
      if (!enabled) return AppColors.border;
      switch (variant) {
        case ButtonVariant.primary:
          return AppColors.primary;
        case ButtonVariant.secondary:
          return AppColors.secondary;
        case ButtonVariant.outline:
          return Colors.transparent;
        case ButtonVariant.danger:
          return AppColors.error;
      }
    }

    Color getTextColor() {
      if (!enabled) return AppColors.textMuted;
      switch (variant) {
        case ButtonVariant.primary:
        case ButtonVariant.secondary:
        case ButtonVariant.danger:
          return Colors.white;
        case ButtonVariant.outline:
          return AppColors.primary;
      }
    }

    BorderSide getBorder() {
      if (variant == ButtonVariant.outline) {
        return BorderSide(
          color: enabled ? AppColors.primary : AppColors.border,
          width: 1.75,
        );
      }
      return BorderSide.none;
    }

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: getBgColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
          side: getBorder(),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          splashColor: Colors.white.withOpacity(0.18),
          highlightColor: Colors.white.withOpacity(0.08),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (leadingIcon != null) ...[
                          Icon(leadingIcon, size: 20, color: getTextColor()),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.button.copyWith(
                              color: getTextColor(),
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        if (trailingIcon != null) ...[
                          const SizedBox(width: 10),
                          Icon(trailingIcon, size: 20, color: getTextColor()),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
