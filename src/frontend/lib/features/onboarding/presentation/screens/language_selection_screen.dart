import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/services/language_controller.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/section_card.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late String _selectedLanguageCode;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingSequence = false;

  @override
  void initState() {
    super.initState();
    _selectedLanguageCode = LanguageController.instance.currentLanguageCode;

    // Play sequence automatically on init
    _playVoiceSequence();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playVoiceSequence() async {
    if (_isPlayingSequence) return;

    setState(() {
      _isPlayingSequence = true;
    });

    try {
      await _audioPlayer.stop();
      // Play first audio
      await _audioPlayer.play(AssetSource('audio/english/selectlanguage.mp3'));
      await _audioPlayer.onPlayerComplete.first;

      if (!mounted) return;

      // Play second audio sequentially right after the first finishes
      await _audioPlayer.play(AssetSource('audio/hindi/selectlanguage.mp3'));
      await _audioPlayer.onPlayerComplete.first;
    } catch (e) {
      debugPrint('Error in audio sequence: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingSequence = false;
        });
      }
    }
  }

  void _onLanguageSelected(String code) {
    try {
      _isPlayingSequence = false;
      _audioPlayer.stop();
    } catch (_) {}

    setState(() {
      _selectedLanguageCode = code;
    });

    LanguageController.instance.setLanguage(code);

    if (mounted) {
      Navigator.pushNamed(context, AppRoutes.roleSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = Responsive.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = LanguageController.instance;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Responsive.maxContentWidth,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _playVoiceSequence,
                              child: Container(
                                height: 38,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.volume_up_outlined, color: Colors.black, size: 16),
                                    const SizedBox(width: 6),
                                    Textbasepo(
                                      tr('Voice') ?? 'Voice Help',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                        child: Textbasepo(tr('select_language'), fontWeight: FontWeight.w700, fontSize: 32),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isTablet ? 3 : 2,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 12.0,
                            childAspectRatio: isTablet ? 1.4 : 1.15,
                          ),
                          itemCount: controller.supportedLanguages.length,
                          itemBuilder: (context, index) {
                            final lang = controller.supportedLanguages[index];
                            final bool isSelected = lang['code'] == _selectedLanguageCode;
                            return InkWell(
                              onTap: () => _onLanguageSelected(lang['code']!),
                              borderRadius: BorderRadius.circular(16.0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF152A56) : AppColors.primaryContainer.withOpacity(0.5))
                                      : (isDark ? AppColors.surfaceDark : AppColors.surfaceElevated),
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.border),
                                    width: isSelected ? 2.0 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? AppColors.primary.withOpacity(0.15)
                                          : Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                                      offset: const Offset(0, 2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          lang['nativeName']!,
                                          style: AppTextStyles.titleLarge.copyWith(
                                            color: isSelected
                                                ? (isDark ? AppColors.highlight : AppColors.primary)
                                                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            LucideIcons.circle_check,
                                            color: AppColors.primary,
                                            size: 20,
                                          )
                                        else
                                          Icon(
                                            LucideIcons.chevron_right,
                                            color: isDark ? AppColors.textMutedDark : AppColors.textMuted.withOpacity(0.6),
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lang['name']!,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          lang['sample']!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}