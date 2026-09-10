import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_card.dart';

class AiPatientDocScreen extends StatefulWidget {
  const AiPatientDocScreen({super.key});

  @override
  State<AiPatientDocScreen> createState() => _AiPatientDocScreenState();
}

class _AiPatientDocScreenState extends State<AiPatientDocScreen> {
  // Editable link state
  bool _isEditingLink = false;
  late TextEditingController _linkController;

  final List<String> _uploadedPrescriptions = [
    'RX_Ayush_OPD_2026_Patel.pdf (1.2 MB)',
  ];

  @override
  void initState() {
    super.initState();
    _linkController = TextEditingController(
      text: 'https://abdm.gov.in/health-records/patel-rajesh-91-4820',
    );
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  void _toggleEditLink() {
    if (_isEditingLink) {
      // Save action
      setState(() {
        _isEditingLink = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('EHR external portal link saved successfully.'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Enter edit mode
      setState(() {
        _isEditingLink = true;
      });
    }
  }

  void _openUploadPrescriptionDialog(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upload Patient Prescription / Rx',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Upload signed doctor prescriptions, rasashala formulations, or diet chart PDFs for cloud EHR synchronization.',
                style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _uploadedPrescriptions.add(
                      'Signed_Prescription_DrVarma_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}.pdf (680 KB)',
                    );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Prescription document indexed and signed successfully.'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.highlight.withOpacity(0.4) : AppColors.primary.withOpacity(0.4),
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF132F6E) : AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(LucideIcons.file_plus, color: isDark ? AppColors.highlight : AppColors.primary, size: 28),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Select Prescription PDF / Photo',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isDark ? AppColors.highlight : AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fast OCR Parsing • ABDM FHIR standard',
                        style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      title: tr('ai_patient_clinical_doc'),
      subtitle: 'Rajesh Patel (42M) • Token #201 • ABHA: 91-4820-9381-2091',
      roleBadge: 'CLINICAL EHR',
      actions: [
        IconButton(
          icon: Icon(LucideIcons.printer, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          tooltip: 'Print Summary',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sent to OPD Network Printer.'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Quick Header Card
            SectionCard(
              backgroundColor: isDark ? AppColors.surfaceVariantDark.withOpacity(0.7) : AppColors.surfaceVariant.withOpacity(0.7),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      'RP',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Rajesh Patel',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF132F6E) : AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'PITTA-VATA',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isDark ? AppColors.highlight : AppColors.primaryDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Age: 42 yrs • Male • Blood: B+ • Weight: 74 kg',
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

            // AI Generated Summary Section
            SectionCard(
              title: 'AI Diagnostic Synthesizer',
              subtitle: 'Classical Ayurvedic Rogi-Roga Pariksha breakdown',
              headerIcon: LucideIcons.sparkles,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          'Samprapti Ghataka (Pathogenesis)',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isDark ? AppColors.highlight : AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• Dosha: Pitta (Vidagdha) with Vata Anubandha\n'
                          '• Dushya: Rasa, Rakta, and Asthi Dhatu\n'
                          '• Agni: Tikshnagni with intermittent Vishamagni\n'
                          '• Srotas: Annavaha & Purishavaha Srotodushti\n'
                          '• Roga Marga: Abhyantara (Internal GI Tract)',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Clinical Evaluation Summary:',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Patient presents with a 3-week history of severe post-prandial heartburn (Urdhvaga Amlapitta) triggered by spicy dietary triggers. Concurrently notes early morning lumbar stiffness. Dashavidha Pariksha confirms Madhyama Sara vitality with adequate physical resilience.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Editable External Link Field Section
            SectionCard(
              title: 'External ABDM / EHR Record Link',
              subtitle: 'Direct link to national health repository or external scans',
              headerIcon: LucideIcons.link,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _isEditingLink
                            ? TextField(
                                controller: _linkController,
                                style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.highlight : AppColors.primaryDark),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: AppColors.primary),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: AppColors.primary),
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                                ),
                                child: Text(
                                  _linkController.text,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark ? AppColors.highlight : AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                      ),
                      const SizedBox(width: 8),

                      // Edit / Save Toggle Button
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: _isEditingLink
                              ? AppColors.primary
                              : (isDark ? const Color(0xFF132F6E) : AppColors.primaryContainer),
                          foregroundColor: _isEditingLink
                              ? Colors.white
                              : (isDark ? AppColors.highlight : AppColors.primaryDark),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: Icon(
                          _isEditingLink ? LucideIcons.save : LucideIcons.pencil,
                          size: 20,
                        ),
                        tooltip: _isEditingLink ? 'Save Link' : 'Edit Link',
                        onPressed: _toggleEditLink,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isEditingLink
                        ? 'Tap save icon to persist URL changes to patient metadata.'
                        : 'Tap pencil icon to update external FHIR diagnostic URL.',
                    style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Prescription Management & Upload Section
            SectionCard(
              title: 'Prescriptions & Clinical Documents',
              subtitle: 'Active e-prescriptions and Ayurvedic formulations',
              headerIcon: LucideIcons.pill,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_uploadedPrescriptions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border, style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          Icon(LucideIcons.file_text, size: 32, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                          const SizedBox(height: 8),
                          Text(
                            'No Prescriptions Uploaded Yet',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Upload digitized Ayush prescription, diet advisory, or panchakarma protocol PDF.',
                            style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ..._uploadedPrescriptions.map(
                      (rx) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.file_text, color: isDark ? AppColors.highlight : AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                rx,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(LucideIcons.eye, size: 18, color: isDark ? AppColors.highlight : AppColors.primary),
                              tooltip: 'Preview Rx',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Opening $rx in preview viewer.'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(LucideIcons.trash_2, size: 18, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                              tooltip: 'Delete',
                              onPressed: () {
                                setState(() {
                                  _uploadedPrescriptions.remove(rx);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Upload Prescription Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.highlight : AppColors.primary,
                      side: BorderSide(color: isDark ? AppColors.highlight : AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(LucideIcons.file_up, size: 18),
                    label: const Text('Upload Prescription / Diet Chart'),
                    onPressed: () => _openUploadPrescriptionDialog(isDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Back to Patient List / Dashboard Buttons
            PrimaryButton(
              label: 'Back to Patient List',
              leadingIcon: LucideIcons.arrow_left,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
