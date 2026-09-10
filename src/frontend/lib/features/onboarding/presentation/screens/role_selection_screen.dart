import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hive/hive.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_scaffold.dart';
import 'package:lottie/lottie.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _audioStep = 0; // 0: Idle, 1: Playing First, 2: Playing Second

  @override
  void initState() {
    super.initState();

    // Listen for completion events to chain a second audio file if needed
    _audioPlayer.onPlayerComplete.listen((_) {
      if (_audioStep == 1) {
        _audioStep = 2;
        _playSecondAudio();
      } else {
        _audioStep = 0;
      }
    });

    _playIntroAudio();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playIntroAudio() async {
    _audioStep = 1;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/hindi/patientordoctorselect.mp3'));
    } catch (e) {
      debugPrint("Error playing intro audio: $e");
      _audioStep = 0;
    }
  }

  Future<void> _playSecondAudio() async {
    try {
      if (!mounted) return;
      // Replace with your second file path if you have one, or remove/keep as stub
      // await _audioPlayer.play(AssetSource('hindi/second_audio.mp3'));
    } catch (e) {
      debugPrint("Error playing second audio: $e");
      _audioStep = 0;
    }
  }

  void _onNavigation(String route) {
    try {
      _audioStep = 0;
      _audioPlayer.stop();
    } catch (_) {}
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = Responsive.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // TOP BAR: BACK BUTTON & VOICE HELP BUTTON

              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 16.0, top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A), size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    GestureDetector(
                      onTap: _playIntroAudio,
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.volume_up_outlined, color: Color(0xFF0F172A), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              tr('Voice') ?? 'Voice Help',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Textbasepo(
                  tr('select_role'),
                  fontWeight: FontWeight.w700,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                  child: Column(
                    children: [

                      // patient

                      Expanded(
                        flex: 2,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                      "assets/lottie/patient.json",
                                      width: 150,
                                      height: 150,
                                    ),
                                    const SizedBox(height: 10),
                                    Textbasepo(
                                      tr('role_patient_title'),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                                      child: Textbasepo(
                                        tr('role_patient_sub'),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child: ElevatedButton(
                                              onPressed: () => _onNavigation(AppRoutes.login),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Textbasepo(tr('next'), fontWeight: FontWeight.w700, fontSize: 18),
                                                  const SizedBox(width: 8),
                                                  const Icon(Icons.arrow_forward_sharp, color: Colors.white)
                                                ],
                                              )
                                          )
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () {
                                    // info action
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // doctor

                      Expanded(
                        flex: 1,
                        child: Material(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _onNavigation(AppRoutes.doctorHome),
                            child: Stack(
                              children: [
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Lottie.asset(
                                        "assets/lottie/doctor.json",
                                        width: 150,
                                        height: 150,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 40),
                                            Textbasepo(
                                              tr('role_doctor_title'),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 25),
                                              child: Textbasepo(
                                                tr('role_doctor_sub'),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                textAlign: TextAlign.left,
                                                overflow: TextOverflow.ellipsis,
                                                max: 2,
                                                height: 1.1,
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 20),
                                              child: Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Container(
                                                  height: 30,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                      color: Colors.blueAccent,
                                                      borderRadius: BorderRadius.circular(15)
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Textbasepo(tr('next'), fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
                                                      const SizedBox(width: 2),
                                                      const Icon(Icons.arrow_forward_sharp, color: Colors.white, size: 15),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: const Icon(Icons.info_outline),
                                    onPressed: () {
                                      // data
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // help

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.hand_helping,
                          size: 18,
                          color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Textbasepo(
                            "Need assistance? Press the kiosk call button or ask the desk coordinator",
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}