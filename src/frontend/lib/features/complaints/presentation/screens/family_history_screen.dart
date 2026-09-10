import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_card.dart';

class MedicalHistoryItem {
  final String id;
  final String condition;
  final String relation;

  MedicalHistoryItem({
    required this.id,
    required this.condition,
    required this.relation,
  });
}

class SurgicalHistoryItem {
  final String id;
  final String procedure;
  final String year;
  final String hospital;

  SurgicalHistoryItem({
    required this.id,
    required this.procedure,
    required this.year,
    required this.hospital,
  });
}

class FamilyHistoryScreen extends StatefulWidget {
  const FamilyHistoryScreen({super.key});

  @override
  State<FamilyHistoryScreen> createState() => _FamilyHistoryScreenState();
}

class _FamilyHistoryScreenState extends State<FamilyHistoryScreen> {
  // Medical History State
  final TextEditingController _medicalConditionController = TextEditingController();
  String _selectedRelation = 'Father';
  final List<String> _relations = [
    'Father',
    'Mother',
    'Paternal Grandparent',
    'Maternal Grandparent',
    'Sibling',
    'Self (Past Diagnosis)',
  ];

  final List<MedicalHistoryItem> _medicalList = [
    MedicalHistoryItem(
      id: '1',
      condition: 'Type-2 Diabetes Mellitus (Madhumeha)',
      relation: 'Father',
    ),
    MedicalHistoryItem(
      id: '2',
      condition: 'Hypertension (Uchha Raktachapa)',
      relation: 'Mother',
    ),
    MedicalHistoryItem(
      id: '3',
      condition: 'Rheumatoid Arthritis (Amavata)',
      relation: 'Maternal Grandparent',
    ),
  ];

  // Surgical History State
  final TextEditingController _surgeryProcedureController = TextEditingController();
  final TextEditingController _surgeryYearController = TextEditingController();

  final List<SurgicalHistoryItem> _surgicalList = [
    SurgicalHistoryItem(
      id: '1',
      procedure: 'Laparoscopic Appendectomy',
      year: '2019',
      hospital: 'District Civil Hospital',
    ),
  ];

  bool _isMedicalExpanded = true;
  bool _isSurgicalExpanded = true;

  @override
  void dispose() {
    _medicalConditionController.dispose();
    _surgeryProcedureController.dispose();
    _surgeryYearController.dispose();
    super.dispose();
  }

  void _addMedicalCondition() {
    final text = _medicalConditionController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a condition or select a quick tag.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _medicalList.insert(
        0,
        MedicalHistoryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          condition: text,
          relation: _selectedRelation,
        ),
      );
      _medicalConditionController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$text added under $_selectedRelation history.'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addSurgicalRecord() {
    final procedure = _surgeryProcedureController.text.trim();
    final year = _surgeryYearController.text.trim().isNotEmpty
        ? _surgeryYearController.text.trim()
        : 'Approx. past';

    if (procedure.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the surgery or procedure name.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _surgicalList.insert(
        0,
        SurgicalHistoryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          procedure: procedure,
          year: year,
          hospital: 'Reported History',
        ),
      );
      _surgeryProcedureController.clear();
      _surgeryYearController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$procedure ($year) added to surgical records.'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onCompleteAssessment(bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF132F6E) : AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.circle_check, color: isDark ? AppColors.highlight : AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Assessment Complete!',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isDark ? AppColors.highlight : AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All 6 diagnostic stages have been recorded successfully in the ABDM clinical registry:',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _buildSummaryCheckItem('Prakriti baseline: Pitta-Vata (Tikshnagni)', isDark),
              _buildSummaryCheckItem('Active Vikriti: Pitta Hyperacidity mapped', isDark),
              _buildSummaryCheckItem('Sara Pariksha: Madhyama Vitality', isDark),
              _buildSummaryCheckItem('Chief Complaints & Family History saved', isDark),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
              },
              child: Text(
                'Back to Home',
                style: AppTextStyles.button.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.aiSummary);
              },
              child: const Text('View AI Summary'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCheckItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.check, size: 16, color: isDark ? AppColors.highlight : AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
              tr('family_history'),
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'STEP 6 OF 6',
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark ? AppColors.highlight : AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hereditary predispositions (Kula Pravrutta) and past interventions',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // 1. Expandable Medical & Hereditary History Section
            SectionCard(
              title: 'Medical & Hereditary History',
              subtitle: 'Chronicle familial health conditions (Kula Rogas)',
              headerIcon: LucideIcons.users,
              trailing: IconButton(
                icon: Icon(
                  _isMedicalExpanded
                      ? LucideIcons.chevron_up
                      : LucideIcons.chevron_down,
                  color: isDark ? AppColors.highlight : AppColors.primary,
                ),
                onPressed: () => setState(() => _isMedicalExpanded = !_isMedicalExpanded),
              ),
              child: AnimatedCrossFade(
                firstChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Condition text field
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _medicalConditionController,
                            style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'e.g. Asthma, Thyroid, Hypertension...',
                              hintStyle: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                              prefixIcon: Icon(LucideIcons.stethoscope, color: isDark ? AppColors.highlight : AppColors.primary, size: 20),
                              filled: true,
                              fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Relation dropdown
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedRelation,
                                dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
                                isExpanded: true,
                                icon: Icon(LucideIcons.chevron_down, size: 18, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary),
                                items: _relations.map((rel) {
                                  return DropdownMenuItem<String>(
                                    value: rel,
                                    child: Text(
                                      rel,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedRelation = val);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Add button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(LucideIcons.plus, size: 18),
                        label: const Text('Add Condition'),
                        onPressed: _addMedicalCondition,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // List of added items
                    if (_medicalList.isEmpty)
                      Text(
                        'No medical history conditions added.',
                        style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                      )
                    else
                      ..._medicalList.map((item) => _buildMedicalItemCard(item, isDark)),
                  ],
                ),
                secondChild: const SizedBox.shrink(),
                crossFadeState: _isMedicalExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 250),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Expandable Surgical & Interventions Section
            SectionCard(
              title: 'Surgical & Interventions History',
              subtitle: 'Past operations, fractures, or major hospitalizations',
              headerIcon: LucideIcons.activity,
              trailing: IconButton(
                icon: Icon(
                  _isSurgicalExpanded
                      ? LucideIcons.chevron_up
                      : LucideIcons.chevron_down,
                  color: isDark ? AppColors.highlight : AppColors.primary,
                ),
                onPressed: () => setState(() => _isSurgicalExpanded = !_isSurgicalExpanded),
              ),
              child: AnimatedCrossFade(
                firstChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Procedure text field
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _surgeryProcedureController,
                            style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'e.g. Gallbladder, Hernia, Knee surgery...',
                              hintStyle: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                              prefixIcon: Icon(LucideIcons.syringe, color: isDark ? AppColors.highlight : AppColors.primary, size: 20),
                              filled: true,
                              fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Year input
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _surgeryYearController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Year (e.g. 2021)',
                              hintStyle: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                              prefixIcon: Icon(LucideIcons.calendar, color: isDark ? AppColors.highlight : AppColors.primary, size: 18),
                              filled: true,
                              fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Add button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(LucideIcons.plus, size: 18),
                        label: const Text('Add Surgery Record'),
                        onPressed: _addSurgicalRecord,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // List of surgical records
                    if (_surgicalList.isEmpty)
                      Text(
                        'No surgical records reported.',
                        style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                      )
                    else
                      ..._surgicalList.map((item) => _buildSurgicalItemCard(item, isDark)),
                  ],
                ),
                secondChild: const SizedBox.shrink(),
                crossFadeState: _isSurgicalExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 250),
              ),
            ),
            const SizedBox(height: 24),

            // Complete Assessment Button
            PrimaryButton(
              label: tr('complete_assessment'),
              leadingIcon: LucideIcons.circle_check,
              onPressed: () => _onCompleteAssessment(isDark),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalItemCard(MedicalHistoryItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark.withOpacity(0.6) : AppColors.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF132F6E) : AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.relation,
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark ? AppColors.highlight : AppColors.primaryDark,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.condition,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(LucideIcons.x, size: 18, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
            tooltip: 'Remove',
            onPressed: () {
              setState(() {
                _medicalList.removeWhere((x) => x.id == item.id);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSurgicalItemCard(SurgicalHistoryItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark.withOpacity(0.6) : AppColors.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2E2206) : AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.calendar, size: 12, color: isDark ? const Color(0xFFFFD466) : AppColors.onSecondaryContainer),
                const SizedBox(width: 4),
                Text(
                  item.year,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark ? const Color(0xFFFFD466) : AppColors.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.procedure,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.hospital,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(LucideIcons.x, size: 18, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
            tooltip: 'Remove',
            onPressed: () {
              setState(() {
                _surgicalList.removeWhere((x) => x.id == item.id);
              });
            },
          ),
        ],
      ),
    );
  }
}