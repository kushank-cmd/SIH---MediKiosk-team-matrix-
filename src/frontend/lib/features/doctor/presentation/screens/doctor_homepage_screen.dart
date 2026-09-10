import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/section_card.dart';

class DoctorHomepageScreen extends StatelessWidget {
  const DoctorHomepageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isTablet = Responsive.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      title: tr('doctor_dashboard'),
      subtitle: 'Dr. S. Varma (BAMS, MD Ayur) • OPD Station #04',
      roleBadge: 'CLINICAL PORTAL',
      actions: [
        IconButton(
          icon: Icon(LucideIcons.bell, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary),
          tooltip: 'Notifications',
          onPressed: () {},
        ),
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
            // Clinical Session Hero Banner
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
                        'AYUSH CLINICAL DESK',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark ? AppColors.highlight : AppColors.primaryContainer,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'LIVE OPD ACTIVE',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome back, Dr. Varma',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All Dashavidha Pariksha assessments and ABHA records are synchronized.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stat Cards Row
            Text(
              'OPD Performance Overview',
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    isDark: isDark,
                    title: 'Total Patients',
                    count: '24',
                    subtitle: 'Today Registered',
                    icon: LucideIcons.users,
                    color: AppColors.primary,
                    bgColor: isDark ? const Color(0xFF132F6E) : AppColors.primaryContainer.withOpacity(0.4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    isDark: isDark,
                    title: 'Pending Reviews',
                    count: '06',
                    subtitle: 'AI Triage Queue',
                    icon: LucideIcons.clock,
                    color: AppColors.secondary,
                    bgColor: isDark ? const Color(0xFF2E2206) : AppColors.secondaryContainer.withOpacity(0.4),
                  ),
                ),
                if (isTablet) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      isDark: isDark,
                      title: 'Completed Consults',
                      count: '18',
                      subtitle: 'Prescriptions Issued',
                      icon: LucideIcons.circle_check,
                      color: const Color(0xFF3B9B78),
                      bgColor: const Color(0xFF3B9B78).withOpacity(0.12),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Main Navigation Tiles
            Text(
              'Clinical Modules & Navigation',
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            // Navigation Tile 1: Patient List
            _buildNavCard(
              context: context,
              isDark: isDark,
              title: tr('patient_triage_list'),
              subtitle: 'Browse all active clinic patients, consultation statuses, and token priorities.',
              badgeText: '6 IN QUEUE',
              icon: LucideIcons.list,
              accentColor: AppColors.primary,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.patientList);
              },
            ),
            const SizedBox(height: 12),

            // Navigation Tile 2: AI Patient Doc
            _buildNavCard(
              context: context,
              isDark: isDark,
              title: tr('ai_patient_clinical_doc'),
              subtitle: 'Inspect AI-synthesized Dashavidha Pariksha, manage e-prescriptions, and update links.',
              badgeText: 'INTELLIGENCE DESK',
              icon: LucideIcons.sparkles,
              accentColor: AppColors.accent,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.aiPatientDoc);
              },
            ),
            const SizedBox(height: 12),

            // Navigation Tile 3: Patient Mode Switch (Demo convenience)
            _buildNavCard(
              context: context,
              isDark: isDark,
              title: 'Switch to Patient Portal View',
              subtitle: 'Test self-service AYUSH assessments, Prakriti quizzes, and booking flows.',
              badgeText: 'DEMO SWITCH',
              icon: LucideIcons.user,
              accentColor: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
              onTap: () {
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required String title,
    required String count,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                count,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevron_right, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
