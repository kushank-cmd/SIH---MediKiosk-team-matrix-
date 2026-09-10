import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/section_card.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      title: tr('doctor_dashboard'),
      subtitle: 'Dr. S. Varma (BAMS, MD Ayur) • Station #04',
      roleBadge: 'CLINICAL PORTAL',
      actions: [
        IconButton(
          icon: Icon(LucideIcons.log_out, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary),
          tooltip: 'Switch Role',
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.roleSelection),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clinical Overview
            SectionCard(
              backgroundColor: isDark ? const Color(0xFF0C2219) : AppColors.primary,
              borderColor: isDark ? const Color(0xFF134A38) : AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AYUSH Consultation Session',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark ? AppColors.highlight : AppColors.primaryContainer,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '8 PATIENTS IN QUEUE',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome to OPD Station 4',
                    style: AppTextStyles.displaySmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prakriti assessment questionnaires and Nadi pariksha logs are live synchronized.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Active Waiting Queue',
              style: AppTextStyles.headlineSmall.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Queue item sample
            SectionCard(
              title: 'Aditya Sharma (34M) • Token #201',
              subtitle: 'Chief Complaint: Chronic Migraine (Pitta Vitiation) • Wait: 12m',
              leftAccentColor: AppColors.primary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prakriti: Pitta-Kapha (Dominant)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.highlight : AppColors.accent,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Starting consultation for Token #201'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Start Consultation'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
