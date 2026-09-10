import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/services/audio_service.dart';

class MedicalProfileFlagScreen extends StatefulWidget {
  const MedicalProfileFlagScreen({super.key});

  @override
  State<MedicalProfileFlagScreen> createState() => _MedicalProfileFlagScreenState();
}

class _MedicalProfileFlagScreenState extends State<MedicalProfileFlagScreen> {
  bool _isFastStateChecked = true;
  bool _noAcuteEmergencyChecked = true;
  bool _consentChecked = true;

  void _playVoiceHelp() {
    AudioService.instance.playVoiceHelp('clinical_assessment.mp3');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final fg = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Integrated Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: Navigator.of(context).pop, icon: Icon(Icons.arrow_back_ios_new_sharp,size: 20,)),
                  Expanded(
                    child: Text(
                      tr('clinical_assessment') ?? 'Clinical Assessment',
                      style: AppTextStyles.headlineSmall.copyWith(color: fg, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _playVoiceHelp,
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.volume_2, color: AppColors.primary, size: 16),
                              const SizedBox(width: 6),
                              Text(tr('Voice') ?? 'Audio', style: AppTextStyles.labelSmall.copyWith(color: fg, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              //
              // // Overview Banner
              // SectionCard(
              //   backgroundColor: isDark ? const Color(0xFF0C2219) : AppColors.primaryContainer.withValues(alpha: 0.4),
              //   borderColor: isDark ? const Color(0xFF134A38) : AppColors.primary.withValues(alpha: 0.3),
              //   leftAccentColor: AppColors.primary,
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Container(
              //         padding: const EdgeInsets.all(10),
              //         decoration: BoxDecoration(
              //           color: AppColors.primary,
              //           borderRadius: BorderRadius.circular(12),
              //         ),
              //         child: const Icon(
              //           LucideIcons.sprout,
              //           color: Colors.white,
              //           size: 24,
              //         ),
              //       ),
              //       const SizedBox(width: 14),
              //       // Expanded(
              //       //   child: Column(
              //       //     crossAxisAlignment: CrossAxisAlignment.start,
              //       //     children: [
              //       //       Text(
              //       //         'Holistic Health & Prakriti Protocol',
              //       //         style: AppTextStyles.titleMedium.copyWith(
              //       //           color: isDark ? AppColors.highlight : AppColors.primaryDark,
              //       //           fontWeight: FontWeight.w700,
              //       //         ),
              //       //       ),
              //       //       const SizedBox(height: 4),
              //       //       Text(
              //       //         'This interactive assessment measures your bio-energetic constitution (Prakriti), current doshic state (Vikriti), tissue vitality (Sara), and symptoms to curate personalized AYUSH recommendations.',
              //       //         style: AppTextStyles.bodySmall.copyWith(
              //       //           color: fg,
              //       //           height: 1.45,
              //       //         ),
              //       //       ),
              //       //     ],
              //       //   ),
              //       // ),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 16),

              SectionCard(
                title: 'Assessment Phases',
                subtitle: '6-stage standardized evaluation according to Charaka Samhita',
                headerIcon: LucideIcons.list_ordered,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    children: [
                      _buildTimelineNode(
                        icon: LucideIcons.sliders_horizontal,
                        stepNumber: '01',
                        title: 'Ayush Consultation Mode',
                        description: 'Select between Comprehensive Guided or Rapid Screening mode.',
                        isCurrent: true,
                        isFirst: true,
                        isLast: false,
                        isDark: isDark,
                      ),
                      _buildTimelineNode(
                        icon: LucideIcons.book_open,
                        stepNumber: '02',
                        title: 'Dashavidha Pariksha Roadmap',
                        description: '10 classical diagnostic dimensions overview.',
                        isCurrent: false,
                        isFirst: false,
                        isLast: false,
                        isDark: isDark,
                      ),
                      _buildTimelineNode(
                        icon: LucideIcons.fingerprint_pattern,
                        stepNumber: '03',
                        title: 'Prakriti Constitution Mapping',
                        description: 'Vata, Pitta, and Kapha genetic dosha baseline.',
                        isCurrent: false,
                        isFirst: false,
                        isLast: false,
                        isDark: isDark,
                      ),
                      _buildTimelineNode(
                        icon: LucideIcons.activity,
                        stepNumber: '04',
                        title: 'Vikriti & Dhatu Sara Analysis',
                        description: 'Current pathology and seven tissue strength levels.',
                        isCurrent: false,
                        isFirst: false,
                        isLast: false,
                        isDark: isDark,
                      ),
                      _buildTimelineNode(
                        icon: LucideIcons.mic,
                        stepNumber: '05',
                        title: 'Chief Complaints & History',
                        description: 'Voice/text symptoms and hereditary clinical timeline.',
                        isCurrent: false,
                        isFirst: false,
                        isLast: true,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Pre-Assessment Clinical Checklist in a Horizontal Scrollable Row
              SectionCard(
                title: 'Pre-Assessment Clinical Checklist',
                subtitle: 'Verify physiological state for accurate dosha inference',
                headerIcon: LucideIcons.shield_check,
                child: SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      SizedBox(
                        width: 130,
                        child: _buildChecklistCard(
                          isDark: isDark,
                          title: 'No acute emergency',
                          subtitle: 'No severe crushing chest pain, dyspnea, or sudden paralysis.',
                          value: _noAcuteEmergencyChecked,
                          onChanged: (val) => setState(() => _noAcuteEmergencyChecked = val ?? false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 130,
                        child: _buildChecklistCard(
                          isDark: isDark,
                          title: 'Meal status logged',
                          subtitle: 'Aids accurate Agni (digestive fire) calculation.',
                          value: _isFastStateChecked,
                          onChanged: (val) => setState(() => _isFastStateChecked = val ?? false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 130,
                        child: _buildChecklistCard(
                          isDark: isDark,
                          title: 'Digital consent',
                          subtitle: 'Authorize secure ABDM encrypted record processing.',
                          value: _consentChecked,
                          onChanged: (val) => setState(() => _consentChecked = val ?? false),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Primary CTA Button
              PrimaryButton(
                label: 'Begin AYUSH Assessment',
                leadingIcon: LucideIcons.play,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.ayushMode);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineNode({
    required IconData icon,
    required String stepNumber,
    required String title,
    required String description,
    bool isCurrent = false,
    required bool isFirst,
    required bool isLast,
    required bool isDark,
  }) {
    final primaryColor = AppColors.primary;
    final nodeColor = isCurrent ? primaryColor : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant);
    final borderColor = isCurrent ? primaryColor : (isDark ? AppColors.borderDark : AppColors.border);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    flex: 1,
                    child: Container(width: 2, color: primaryColor.withValues(alpha: 0.3)),
                  )
                else
                  const Spacer(),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: nodeColor,
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 13,
                      color: isCurrent ? Colors.white : (isDark ? AppColors.textMutedDark : AppColors.textSecondary),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    flex: 2,
                    child: Container(width: 2, color: primaryColor.withValues(alpha: 0.3)),
                  )
                else
                  const Spacer(),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? (isDark ? AppColors.surfaceDark : Colors.white)
                      : (isDark ? AppColors.surfaceDark.withValues(alpha: 0.5) : AppColors.surfaceElevated.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent ? primaryColor.withValues(alpha: 0.5) : (isDark ? AppColors.borderDark : AppColors.border),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step $stepNumber',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isCurrent ? primaryColor : (isDark ? AppColors.textMutedDark : AppColors.textSecondary),
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isCurrent ? (isDark ? AppColors.highlight : AppColors.primaryDark) : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: value
              ? (isDark ? AppColors.surfaceDark : AppColors.surfaceElevated)
              : (isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.5) : AppColors.surfaceVariant.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? AppColors.primary.withValues(alpha: 0.4) : (isDark ? AppColors.borderDark : AppColors.border),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    value: value,
                    onChanged: onChanged,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                fontSize: 11,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}