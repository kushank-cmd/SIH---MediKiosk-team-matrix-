import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_card.dart';

class AiSummaryScreen extends StatefulWidget {
  const AiSummaryScreen({super.key});

  @override
  State<AiSummaryScreen> createState() => _AiSummaryScreenState();
}

class _AiSummaryScreenState extends State<AiSummaryScreen> {
  bool _isLoading = true;
  int _generationCount = 1;

  @override
  void initState() {
    super.initState();
    _generateSummary();
  }

  void _generateSummary() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _onRegenerate() {
    setState(() {
      _generationCount++;
    });
    _generateSummary();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('Ai Summary'),
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.share_2, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            tooltip: 'Share Summary',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clinical summary exported to ABDM Health Locker.'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: LoadingIndicator(
            message: 'Synthesizing Dashavidha Pariksha, Prakriti doshas & clinical history...',
            size: 48,
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ABDM-integrated Classical Ayurvedic diagnostic intelligence',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              // Verification Banner
              SectionCard(
                backgroundColor: isDark ? const Color(0xFF132F6E) : AppColors.primaryContainer.withOpacity(0.4),
                borderColor: isDark ? const Color(0xFF1E4B9F) : AppColors.primary.withOpacity(0.5),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.sparkles,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ayush AI Clinical Synthesis v2.4',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: isDark ? AppColors.highlight : AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Derived from Charaka Samhita & CCRAS clinical benchmarks (Revision #$_generationCount)',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Main Formatted AI Card
              SectionCard(
                title: 'Diagnostic Synthesis & Pathological Mapping',
                subtitle: 'Patient: Rajesh Patel (42M) • ABHA ID: 91-4820-9381-2091',
                headerIcon: LucideIcons.brain,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Highlighted Headline
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE26D45).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'PRIMARY SAMPRAPTI',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: const Color(0xFFE26D45),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF132F6E) : AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'PITTA-PRADHAN VATA ANUBANDHA',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isDark ? AppColors.highlight : AppColors.primaryDark,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Amlapitta with Associated Kati Graha (Lower Lumbar Stiffness)',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Formatted Paragraph Body
                    Text(
                      'Clinical Assessment Narrative:',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'The patient exhibits a baseline Pitta-Vata (Tikshnagni) constitutional Prakriti with an acute secondary Vikriti characterized by Vidagdha Ajeerna (hyperacidity, sour eructations, and retrosternal burning). Aggravating factors include high-sodium, pungent dietary habits coupled with irregular work stress. Mild Vata accumulation in the lumbar spine (Asthi-Meda Dhatu involvement) accounts for reported morning stiffness.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Clinical Recommendations Grid
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Suggested Protocol Dimensions:',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isDark ? AppColors.highlight : AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildBulletPoint('Ahara (Diet): Pitta-pacifying cooling diet (Sheetala, Tikta, Madhura Rasas). Avoid late dinners.', isDark),
                          _buildBulletPoint('Vihara (Lifestyle): 15 min Sheetali Pranayama + gentle Kati Chakrasana for spinal flexibility.', isDark),
                          _buildBulletPoint('Aushadha (Formulations): Consider Avipattikar Churna (3g post meals) and Shankha Bhasma under supervision.', isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Regenerate Button
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? AppColors.highlight : AppColors.primary,
                              side: BorderSide(color: isDark ? AppColors.highlight : AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(LucideIcons.rotate_cw, size: 18),
                            label: Text(tr('Regenerate Ai')),
                            onPressed: _onRegenerate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Bottom Action Buttons
              PrimaryButton(
                label: tr('Return to Home'),
                leadingIcon: LucideIcons.house,
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
                },
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  icon: Icon(LucideIcons.stethoscope, size: 18, color: isDark ? AppColors.highlight : AppColors.primary),
                  label: Text('View in Doctor Clinical Portal', style: TextStyle(color: isDark ? AppColors.highlight : AppColors.primary)),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.doctorHome);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.circle_check, size: 16, color: isDark ? AppColors.highlight : AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}