import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sih/app/theme/app_text_styles.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/services/Otplocalization.dart';
import '../../../../core/services/audio_service.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendCountdown = 60;
  Timer? _timer;
  bool _canResend = false;
  bool _isVerifying = false;

  final Color _primaryPurple = const Color(0xFF7A58C2);
  final Color _accentGreen = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _startTimer();
    _playIntroAudio();
  }

  void _playIntroAudio() {
    AudioService.instance.playVoiceHelp('OTPinsert.mp3');
  }

  void _playVoiceHelp() {
    AudioService.instance.playVoiceHelp('OTPinsert.mp3');
  }

  void _startTimer() {
    setState(() {
      _resendCountdown = 30;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final fn in _focusNodes) {
      fn.dispose();
    }
    super.dispose();
  }

  void _onVerify() {
    final enteredOtp = _controllers.map((c) => c.text).join();

    if (enteredOtp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Textbasepo(tr('err_otp_incomplete'), color: Colors.white),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    // Verify the entered OTP against stored service value without generating a new one
    final isValid = OtpService.verifyOtp(enteredOtp);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });

        if (isValid) {
          Navigator.pushNamed(context, AppRoutes.completeProfile);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Textbasepo(tr('err_otp_wrong'), color: Colors.white),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    });
  }

  Future<void> _onResendOtp() async {
    if (!_canResend) return;

    // Generate and send a new OTP code
    await OtpService.generateAndSendOtp();

    _startTimer();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Textbasepo(tr('otp_sent_success') ?? 'OTP sent successfully', color: Colors.white),
          backgroundColor: _primaryPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const textColor = Color(0xFF0F172A);
    const subTextColor = Color(0xFF64748B);

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
        ),
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(28, 12, 28, MediaQuery.of(context).viewInsets.bottom + 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 1. TOP BAR WITH BACK & VOICE HELP BUTTONS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: textColor, size: 24),
                              onPressed: () => Navigator.pop(context),
                            ),
                            GestureDetector(
                              onTap: _playVoiceHelp,
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
                                    const Icon(Icons.volume_up_outlined, color: Color(0xFF0F172A), size: 16),
                                    const SizedBox(width: 6),
                                    Textbasepo(
                                      tr('Voice') ?? 'Voice Help',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(110),
                            child: Image.asset(
                              'assets/images/Otp.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: _primaryPurple.withValues(alpha: 0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: _primaryPurple.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 3. TITLE & SUBTITLE
                        Textbasepo(
                          tr('otp_title') ?? 'Enter OTP',
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          textAlign: TextAlign.center,
                          letterSpacing: -0.5,
                        ),
                        const SizedBox(height: 8),
                        Textbasepo(
                          tr('otp_sub'),
                          fontSize: 13,
                          color: subTextColor,
                          textAlign: TextAlign.center,
                          height: 1.4,
                        ),
                        const SizedBox(height: 36),

                        // 4. 6-BOX OTP INPUT ROW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 44,
                              height: 52,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: TextStyle(
                                  color: _accentGreen,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: InputDecoration(
                                  counterText: "",
                                  filled: true,
                                  fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: _accentGreen, width: 1.5),
                                  ),
                                ),
                                onChanged: (val) {
                                  if (val.isNotEmpty && index < 5) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else if (val.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                },
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 36),

                        // 5. NEXT / VERIFY BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isVerifying ? null : _onVerify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              elevation: 0,
                            ),
                            child: Textbasepo(
                              _isVerifying ? tr('verifying') : tr('next'),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 6. RESEND SECTION
                        Column(
                          children: [
                            Textbasepo(
                              tr('didnt_receive_otp') ?? "Didn't Receive the OTP?",
                              fontSize: 13,
                              color: subTextColor,
                            ),
                            const SizedBox(height: 4),
                            if (_canResend)
                              GestureDetector(
                                onTap: _onResendOtp,
                                child: Textbasepo(
                                  tr('otp_resend_now') ?? 'Resend Code',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _accentGreen,
                                ),
                              )
                            else
                              Textbasepo(
                                tr('otp_resend_in', args: {'seconds': _resendCountdown.toString()}),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _accentGreen,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}