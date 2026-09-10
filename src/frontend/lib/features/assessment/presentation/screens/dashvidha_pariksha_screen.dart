import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/widgets/primary_button.dart';

class DashvidhaParikshaScreen extends StatefulWidget {
  const DashvidhaParikshaScreen({super.key});

  @override
  State<DashvidhaParikshaScreen> createState() => _DashvidhaParikshaScreenState();
}

class _DashvidhaParikshaScreenState extends State<DashvidhaParikshaScreen> {
  // Track individually expanded items in the timeline (defaulting to the first item expanded)
  final Set<int> _expandedIndices = {0};

  final List<Map<String, dynamic>> _examinations = const [
    {'number': 1, 'sanskrit': 'Prakriti Pariksha', 'english': 'Baseline', 'status': 'IN FOCUS', 'icon': LucideIcons.sprout, 'isCurrent': true, 'description': 'Evaluating inherent Vata, Pitta, and Kapha genetic makeup.'},
    {'number': 2, 'sanskrit': 'Vikriti Pariksha', 'english': 'Imbalance', 'status': 'QUEUED', 'icon': LucideIcons.activity, 'isCurrent': false, 'description': 'Detecting active symptoms and environmental pathology.'},
    {'number': 3, 'sanskrit': 'Sara Pariksha', 'english': 'Tissue Essence', 'status': 'QUEUED', 'icon': LucideIcons.layers, 'isCurrent': false, 'description': 'Grading excellence of Rasa, Rakta, Mamsa, Meda, Asthi, Majja, Shukra.'},
    {'number': 4, 'sanskrit': 'Samhanana Pariksha', 'english': 'Body Build', 'status': 'READY', 'icon': LucideIcons.user_check, 'isCurrent': false, 'description': 'Bone density, muscular symmetry, and anatomical stability.'},
    {'number': 5, 'sanskrit': 'Pramana Pariksha', 'english': 'BMI & Metrics', 'status': 'SYNC', 'icon': LucideIcons.ruler, 'isCurrent': false, 'description': 'Calibrated height, weight, circumferences, and body mass index.'},
    {'number': 6, 'sanskrit': 'Satmya Pariksha', 'english': 'Adaptability', 'status': 'QUEUED', 'icon': LucideIcons.leaf, 'isCurrent': false, 'description': 'Tolerance to environmental shifts, rasas (tastes), and climate.'},
    {'number': 7, 'sanskrit': 'Satwa Pariksha', 'english': 'Mental State', 'status': 'QUEUED', 'icon': LucideIcons.brain, 'isCurrent': false, 'description': 'Manasika gunas: Sattva, Rajas, and Tamas psychological balance.'},
    {'number': 8, 'sanskrit': 'Ahara Shakti', 'english': 'Digestion & Agni', 'status': 'QUEUED', 'icon': LucideIcons.flame, 'isCurrent': false, 'description': 'Abhyavaharana (intake) and Jarana (digestion) efficiency.'},
    {'number': 9, 'sanskrit': 'Vyayama Shakti', 'english': 'Endurance', 'status': 'QUEUED', 'icon': LucideIcons.dumbbell, 'isCurrent': false, 'description': 'Karmashakti and tolerance to physical exertion.'},
    {'number': 10, 'sanskrit': 'Vaya Pariksha', 'english': 'Bio Age', 'status': 'DONE', 'icon': LucideIcons.hourglass, 'isCurrent': false, 'description': 'Childhood (Balyavastha), Youth (Madhyamavastha), or Elder (Vridhavastha).'},
  ];

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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: fg, size: 20),
                    onPressed: Navigator.of(context).pop,
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.volume_up_outlined, color: fg, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            tr('Voice') != 'Voice' ? tr('Voice') : 'Voice Help',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: fg,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Center(child: Image.asset('assets/images/dash.png', width: 150,height: 150,)),
              Center(
                child: Text(
                  tr('Dashvidha Pariksha') != 'Dashvidha Pariksha' ? tr('Dashvidha Pariksha') : 'Dashvidha Pariksha',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: fg,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: tr('continue'),
                leadingIcon: LucideIcons.arrow_right,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.prakriti);
                },
              ),
              const SizedBox(height: 18),

              Text('Assessment Roadmap', style: AppTextStyles.titleMedium.copyWith(color: fg, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _examinations.length,
                itemBuilder: (context, index) {
                  final exam = _examinations[index];
                  final bool isCurrent = exam['isCurrent'] as bool;
                  final bool isLast = index == _examinations.length - 1;
                  final bool isExpanded = _expandedIndices.contains(index);

                  // Using a LayoutBuilder combined with Flexible fixes RenderFlex overflow
                  // when animating height changes inside the individual timeline rows.
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isCurrent ? AppColors.primary : (isDark ? AppColors.surfaceDark : AppColors.surfaceVariant),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isCurrent ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.border),
                                      width: isCurrent ? 2.0 : 1.0,
                                    ),
                                  ),
                                  child: isCurrent
                                      ? Text('${exam['number']}', style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13))
                                      : Icon(exam['icon'] as IconData, size: 14, color: muted),
                                ),
                                if (!isLast)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: isCurrent ? AppColors.primary : (isDark ? AppColors.surfaceVariantDark : AppColors.border),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isExpanded) {
                                          _expandedIndices.remove(index);
                                        } else {
                                          _expandedIndices.add(index);
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isCurrent
                                            ? (isDark ? AppColors.surfaceDark : AppColors.surfaceElevated)
                                            : (isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.3) : AppColors.surfaceElevated.withValues(alpha: 0.5)),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isCurrent ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.border),
                                          width: isCurrent ? 1.5 : 1.0,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      exam['sanskrit'] as String,
                                                      style: AppTextStyles.bodyMedium.copyWith(
                                                        color: isCurrent ? (isDark ? AppColors.highlight : AppColors.primaryDark) : fg,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 1),
                                                    Text(
                                                      exam['english'] as String,
                                                      style: AppTextStyles.bodySmall.copyWith(color: muted, fontSize: 11),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: isCurrent ? AppColors.primary.withValues(alpha: 0.12) : (isDark ? AppColors.surfaceDark : AppColors.surfaceVariant),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      exam['status'] as String,
                                                      style: AppTextStyles.labelSmall.copyWith(
                                                        color: isCurrent ? AppColors.primary : muted,
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 9,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Icon(
                                                    isExpanded ? LucideIcons.chevron_up : LucideIcons.chevron_down,
                                                    size: 16,
                                                    color: muted,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          AnimatedCrossFade(
                                            firstChild: const SizedBox(width: double.infinity, height: 0),
                                            secondChild: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 8),
                                                Text(
                                                  exam['description'] as String,
                                                  style: AppTextStyles.bodySmall.copyWith(color: muted, fontSize: 11, height: 1.4),
                                                ),
                                              ],
                                            ),
                                            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                            duration: const Duration(milliseconds: 200),
                                            sizeCurve: Curves.easeInOut,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}