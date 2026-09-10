import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Reusable loading indicator widget with optional message and AYUSH herbal branding accent.
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final bool isOverlay;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 44.0,
    this.color,
    this.isOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 3.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.primary,
            ),
            backgroundColor: AppColors.primaryContainer.withOpacity(0.5),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 18),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );

    if (isOverlay) {
      return Container(
        color: AppColors.background.withOpacity(0.85),
        alignment: Alignment.center,
        child: indicator,
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: indicator,
      ),
    );
  }
}
