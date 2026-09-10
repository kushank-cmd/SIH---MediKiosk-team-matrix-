import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../localization/app_translations.dart';
import '../../app/routes/app_routes.dart';

class VoiceControlButton extends StatefulWidget {
  final String? tooltip;
  final ValueChanged<String>? onTextCaptured;
  final String contextHint;
  final bool extended;

  const VoiceControlButton({
    super.key,
    this.tooltip,
    this.onTextCaptured,
    this.contextHint = 'Describe your symptoms or navigate with voice',
    this.extended = true,
  });

  @override
  State<VoiceControlButton> createState() => _VoiceControlButtonState();
}

class _VoiceControlButtonState extends State<VoiceControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openVoiceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _VoiceAssistantModal(
        contextHint: widget.contextHint,
        onTextCaptured: (text) {
          if (widget.onTextCaptured != null) {
            widget.onTextCaptured!(text);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        elevation: 6,
        shadowColor: AppColors.primary.withValues(alpha: 0.35),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => _openVoiceModal(context),
          customBorder: const CircleBorder(),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryNavy],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
            ),
            alignment: Alignment.center,
            child: const Icon(
              LucideIcons.mic,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _VoiceAssistantModal extends StatefulWidget {
  final String contextHint;
  final ValueChanged<String> onTextCaptured;

  const _VoiceAssistantModal({
    required this.contextHint,
    required this.onTextCaptured,
  });

  @override
  State<_VoiceAssistantModal> createState() => _VoiceAssistantModalState();
}

class _VoiceAssistantModalState extends State<_VoiceAssistantModal> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  bool _isListening = false;
  bool _isSpeaking = false;
  String _recognizedTranscript = 'Tap the microphone and start speaking...';
  final String _selectedLanguage = 'en_IN';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initTts();
    _initSpeech();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();

    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint("TTS Error Output: $msg");
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _speakTranscript() async {
    if (_recognizedTranscript.isEmpty || _recognizedTranscript.startsWith('Tap')) return;

    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
    }

    await _flutterTts.setLanguage(_selectedLanguage);

    if (_isSpeaking) {
      await _flutterTts.stop();
      if (mounted) setState(() => _isSpeaking = false);
    } else {
      var result = await _flutterTts.speak(_recognizedTranscript);
      if (result == 1 && mounted) {
        setState(() => _isSpeaking = true);
      }
    }
  }

  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint('STT Status: $status'),
      onError: (error) => debugPrint('STT Error: $error'),
    );
    if (available && mounted) {
      setState(() {});
      _startListening();
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available && mounted) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: _selectedLanguage,
          onResult: (val) {
            if (mounted) {
              setState(() {
                _recognizedTranscript = val.recognizedWords;
              });
            }
          },
        );
      }
    }
  }

  void _stopListening() async {
    await _speech.stop();
    if (mounted) {
      setState(() => _isListening = false);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.mic, color: AppColors.primary, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AYUSH Live Voice Input',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Real-time Speech Recognition',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      _speech.stop();
                      _flutterTts.stop();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_isListening) {
                          _stopListening();
                        } else {
                          _startListening();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: _isListening
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isListening ? AppColors.primary : AppColors.textMuted,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _isListening ? LucideIcons.mic : LucideIcons.mic_off,
                          color: _isListening ? AppColors.primary : AppColors.textMuted,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isListening ? 'Listening... Speak now' : 'Paused. Tap mic to resume',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _isListening ? AppColors.primary : AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Live Transcript:',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.primaryNavy,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 38,
                          child: ElevatedButton.icon(
                            onPressed: _speakTranscript,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: Icon(
                              _isSpeaking ? LucideIcons.volume_x : LucideIcons.volume_2,
                              size: 16,
                            ),
                            label: Text(
                              _isSpeaking ? 'STOP READING' : 'READ ALOUD',
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"$_recognizedTranscript"',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        _speech.stop();
                        _flutterTts.stop();
                        Navigator.pop(context);
                      },
                      child: Text(tr('cancel')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(LucideIcons.check, size: 16),
                      label: const Text('Apply Voice Input'),
                      onPressed: () {
                        _speech.stop();
                        _flutterTts.stop();
                        widget.onTextCaptured(_recognizedTranscript);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}