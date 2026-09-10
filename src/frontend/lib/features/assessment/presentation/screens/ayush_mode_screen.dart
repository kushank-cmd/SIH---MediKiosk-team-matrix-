import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/widgets/option_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/voice_control_button.dart';

class AyushModeScreen extends StatefulWidget {
  const AyushModeScreen({super.key});

  @override
  State<AyushModeScreen> createState() => _AyushModeScreenState();
}

class _AyushModeScreenState extends State<AyushModeScreen> with SingleTickerProviderStateMixin {
  String _selectedMode = 'guided';
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _playVoiceHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Audio Help: Choose between comprehensive guided check or rapid screening mode.'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final fg = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: VoiceControlButton(
        contextHint: 'Say "Guided mode", "Quick triage", or "Proceed"',
        onTextCaptured: (text) {
          final lower = text.toLowerCase();
          if (lower.contains('guided') || lower.contains('comprehensive')) {
            setState(() => _selectedMode = 'guided');
          } else if (lower.contains('quick') || lower.contains('rapid')) {
            setState(() => _selectedMode = 'quick');
          } else if (lower.contains('proceed') || lower.contains('continue')) {
            Navigator.pushNamed(context, AppRoutes.dashvidhaPariksha);
          }
        },
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              // Custom Header without AppBar + Properly wired Audio/Voice Help Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: Navigator.of(context).pop,
                    icon: const Icon(Icons.arrow_back_ios_new_sharp, size: 20),
                  ),
                  Expanded(
                    child: Text(
                      tr('Clinical Assessment') ?? 'Clinical Assessment',
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

              Text(
                'Select Consultation Workflow',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(color: fg, fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),

              // Option 1: Guided Mode with Expandable Details
              OptionCard(
                title: tr('guided_assessment'),
                description: 'Comprehensive 10-fold examination covering in-depth Prakriti, Vikriti, Agni, and Dhatu Sara vitality.',
                badgeText: 'RECOMMENDED • 8-10 MIN',
                badgeColor: isDark ? const Color(0xFF132F6E) : AppColors.primary.withValues(alpha: 0.12),
                badgeTextColor: isDark ? AppColors.highlight : AppColors.primary,
                isSelected: _selectedMode == 'guided',
                onSelect: () => setState(() => _selectedMode = 'guided'),
              ),
              if (_selectedMode == 'guided') ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.5) : AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Included in Guided Mode',
                        style: AppTextStyles.bodyMedium.copyWith(color: fg, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      _buildTimelineNode(icon: LucideIcons.book_open, title: 'Dashavidha Pariksha', subtitle: '10 comprehensive diagnostic dimensions', isFirst: true, isLast: false, isDark: isDark),
                      _buildTimelineNode(icon: LucideIcons.fingerprint_pattern, title: 'Prakriti Dosha Matrix', subtitle: 'Complete 5-dimension constitutional survey', isFirst: false, isLast: false, isDark: isDark),
                      _buildTimelineNode(icon: LucideIcons.activity, title: 'Vikriti & Dhatu Sara', subtitle: '7-layer vitality and imbalance tracking', isFirst: false, isLast: true, isDark: isDark),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Option 2: Quick Screening Mode with Expandable Details
              OptionCard(
                title: tr('quick_triage'),
                description: 'Essential dosha survey and chief complaints capture. Tailored for rapid OPD pre-check and follow-up reviews.',
                badgeText: 'RAPID • 3-4 MIN',
                badgeColor: isDark ? const Color(0xFF2E2206) : AppColors.accent.withValues(alpha: 0.12),
                badgeTextColor: isDark ? const Color(0xFFFFD466) : AppColors.accent,
                isSelected: _selectedMode == 'quick',
                onSelect: () => setState(() => _selectedMode = 'quick'),
              ),
              if (_selectedMode == 'quick') ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.5) : AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Included in Quick Mode',
                        style: AppTextStyles.bodyMedium.copyWith(color: fg, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      _buildTimelineNode(icon: LucideIcons.compass, title: 'Constitutional Screening', subtitle: 'Rapid Prakriti assessment', isFirst: true, isLast: false, isDark: isDark),
                      _buildTimelineNode(icon: LucideIcons.circle_alert, title: 'Chief Complaints', subtitle: 'Symptom severity and tagging', isFirst: false, isLast: false, isDark: isDark),
                      _buildTimelineNode(icon: LucideIcons.send, title: 'Queue Forwarding', subtitle: 'Immediate routing to doctor token queue', isFirst: false, isLast: true, isDark: isDark),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),

              // Proceed Button
              PrimaryButton(
                label: tr('proceed'),
                leadingIcon: LucideIcons.arrow_right,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.dashvidhaPariksha);
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
    required String title,
    required String subtitle,
    required bool isFirst,
    required bool isLast,
    required bool isDark,
  }) {
    final primaryColor = isDark ? AppColors.highlight : AppColors.primary;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

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
                    color: primaryColor.withValues(alpha: 0.15),
                    border: Border.all(color: primaryColor, width: 1.5),
                  ),
                  child: Icon(icon, size: 14, color: primaryColor),
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
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}