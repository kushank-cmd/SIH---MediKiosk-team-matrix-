import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_card.dart';

class PresentComplaintScreen extends StatefulWidget {
  const PresentComplaintScreen({super.key});

  @override
  State<PresentComplaintScreen> createState() => _PresentComplaintScreenState();
}

class _PresentComplaintScreenState extends State<PresentComplaintScreen> {
  final TextEditingController _complaintController = TextEditingController();

  late stt.SpeechToText _speech;
  bool _isSpeechAvailable = false;
  bool _isListeningVoice = false;

  String _selectedDuration = '1-4 Weeks';
  String _selectedSeverity = 'Moderate';

  final List<String> _durations = ['< 1 Week', '1-4 Weeks', '1-6 Months', '> 6 Months (Chronic)'];
  final List<String> _severities = ['Mild', 'Moderate', 'Severe'];

  final List<String> _quickSymptoms = [
    'Burning Acidity (Amlapitta)',
    'Joint Stiffness (Sandhivata)',
    'Insomnia / Restless Sleep (Anidra)',
    'Low Appetite / Indigestion (Agnimandya)',
    'Headache / Migraine (Shirashoola)',
    'Skin Itching (Kandu)',
    'General Fatigue (Daurbalya)',
  ];

  final List<Map<String, dynamic>> _uploadedDocs = [];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' && _isListeningVoice) {
            setState(() {
              _isListeningVoice = false;
            });
          }
        },
        onError: (error) {
          setState(() {
            _isListeningVoice = false;
          });
        },
      );
      setState(() {
        _isSpeechAvailable = available;
      });
    } catch (_) {
      setState(() {
        _isSpeechAvailable = false;
      });
    }
  }

  @override
  void dispose() {
    _complaintController.dispose();
    super.dispose();
  }

  void _toggleVoiceInput() async {
    if (!_isSpeechAvailable) {
      setState(() {
        _isListeningVoice = !_isListeningVoice;
      });
      if (_isListeningVoice) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _isListeningVoice) {
            setState(() {
              _isListeningVoice = false;
              const capturedText = 'Experiencing recurrent burning sensation in chest after spicy meals.';
              final currentText = _complaintController.text.trim();
              if (currentText.isEmpty) {
                _complaintController.text = capturedText;
              } else {
                _complaintController.text = '$currentText\n$capturedText';
              }
            });
          }
        });
      }
      return;
    }

    if (_isListeningVoice) {
      await _speech.stop();
      setState(() {
        _isListeningVoice = false;
      });
    } else {
      setState(() {
        _isListeningVoice = true;
      });
      await _speech.listen(
        onResult: (result) {
          setState(() {
            final currentText = _complaintController.text.trim();
            if (currentText.isEmpty) {
              _complaintController.text = result.recognizedWords;
            } else {
              _complaintController.text = '$currentText ${result.recognizedWords}';
            }
          });
        },
      );
    }
  }

  void _addQuickSymptom(String symptom) {
    setState(() {
      final currentText = _complaintController.text.trim();
      if (currentText.isEmpty) {
        _complaintController.text = symptom;
      } else if (!currentText.contains(symptom)) {
        _complaintController.text = '$currentText, $symptom';
      }
    });


  }

  Future<void> _pickAndUploadDocument() async {
    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (files.isNotEmpty) {
        final platformFile = files.first;
        final fileName = platformFile.name;
        final fileSizeKb = (platformFile.lengthSync() ?? 0) / 1024;
        final fileSizeStr = fileSizeKb > 1024
            ? '${(fileSizeKb / 1024).toStringAsFixed(1)} MB'
            : '${fileSizeKb.toStringAsFixed(0)} KB';

        setState(() {
          _uploadedDocs.add({
            'name': fileName,
            'size': fileSizeStr,
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully uploaded: $fileName ($fileSizeStr)'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick file: '),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _onProceedToFamilyHistory() {
    Navigator.pushNamed(context, AppRoutes.familyHistory);
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
              tr('Present complain'),

              style: AppTextStyles.titleMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Describe current symptoms, onset, and duration for consultation triage',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Primary Health Symptoms (Pradhana Vedana)',
              subtitle: 'Type or use voice dictation in your preferred language',
              headerIcon: LucideIcons.file_pen_line,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detailed Description',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      InkWell(
                        onTap: _toggleVoiceInput,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isListeningVoice
                                ? (isDark ? const Color(0xFF3B1515) : AppColors.error.withOpacity(0.12))
                                : (isDark ? const Color(0xFF132F6E) : AppColors.primaryContainer),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isListeningVoice
                                  ? (isDark ? const Color(0xFFFF7A7A) : AppColors.error)
                                  : (isDark ? AppColors.highlight : AppColors.primary),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isListeningVoice ? LucideIcons.mic : LucideIcons.mic_off,
                                size: 16,
                                color: _isListeningVoice
                                    ? (isDark ? const Color(0xFFFF7A7A) : AppColors.error)
                                    : (isDark ? AppColors.highlight : AppColors.primary),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isListeningVoice ? 'Listening...' : 'Voice Input',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: _isListeningVoice
                                      ? (isDark ? const Color(0xFFFF7A7A) : AppColors.error)
                                      : (isDark ? AppColors.highlight : AppColors.primary),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _complaintController,
                    maxLines: 4,
                    style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'e.g. Constant heartburn after oily food, joint stiffness in knees for 2 months...',
                      hintStyle: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                      filled: true,
                      fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Quick Add Common Symptoms:',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _quickSymptoms.map((symptom) {
                      return ActionChip(
                        avatar: Icon(LucideIcons.plus, size: 14, color: isDark ? AppColors.highlight : AppColors.primary),
                        label: Text(symptom),
                        labelStyle: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          fontSize: 11,
                        ),
                        backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                        ),
                        onPressed: () => _addQuickSymptom(symptom),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              title: 'Onset & Severity Rating',
              subtitle: 'Clinical time course of primary complaints',
              headerIcon: LucideIcons.timer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration of Symptoms',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _durations.map((dur) {
                      final bool isSelected = _selectedDuration == dur;
                      return ChoiceChip(
                        label: Text(dur),
                        selected: isSelected,
                        selectedColor: isDark ? const Color(0xFF132F6E) : AppColors.primaryContainer,
                        labelStyle: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? (isDark ? AppColors.highlight : AppColors.primaryDark)
                              : (isDark ? AppColors.textMutedDark : AppColors.textSecondary),
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.border),
                          ),
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedDuration = dur);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Severity / Discomfort Level',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _severities.map((sev) {
                      final bool isSelected = _selectedSeverity == sev;
                      Color chipColor = isDark ? AppColors.highlight : AppColors.primary;
                      if (sev == 'Moderate') chipColor = AppColors.secondary;
                      if (sev == 'Severe') chipColor = AppColors.error;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: InkWell(
                            onTap: () => setState(() => _selectedSeverity = sev),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? chipColor.withOpacity(0.15)
                                    : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? chipColor : (isDark ? AppColors.borderDark : AppColors.border),
                                  width: isSelected ? 1.8 : 1.0,
                                ),
                              ),
                              child: Text(
                                sev,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: isSelected ? chipColor : (isDark ? AppColors.textMutedDark : AppColors.textSecondary),
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              title: 'Past Documents & Lab Reports',
              subtitle: 'Attach previous prescriptions or diagnostic panels',
              headerIcon: LucideIcons.file_text,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_uploadedDocs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'No medical documents or lab reports attached yet.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  else
                    ..._uploadedDocs.map(
                          (doc) => Container(
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
                                '${doc['name']} (${doc['size']})',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(LucideIcons.x, size: 16, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                              onPressed: () {
                                setState(() {
                                  _uploadedDocs.remove(doc);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: _pickAndUploadDocument,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.file_up, size: 18, color: isDark ? AppColors.highlight : AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            '+ Upload Past Medical Document / Lab Report',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isDark ? AppColors.highlight : AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: tr('Proceed To History'),
              leadingIcon: LucideIcons.arrow_right,
              onPressed: _onProceedToFamilyHistory,
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}