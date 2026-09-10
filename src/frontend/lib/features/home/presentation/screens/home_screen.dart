import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/services/Otplocalization.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/language_controller.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/widgets/voice_control_button.dart';

class _InfoCardData {
  const _InfoCardData({
    required this.icon,
    required this.badge,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String badge;
  final String title;
  final String subtitle;
}

class HomeShowcaseManager {
  static const Map<String, String> _englishAudio = {
    'voiceHelpToggle': 'voiceassistance.mp3',
    'assessment': 'ayurvadaassessment.mp3',
    'quickAccess': 'guided_quick_opt.mp3',
    'mic': 'voiceassistance.mp3',
    'aiSummary': 'healthreportsummary.mp3',
    'ayurveda': 'ayurvedicclinicview.mp3',
  };

  static const Map<String, String> _hindiAudio = {
    'voiceHelpToggle': 'homescreen_voice_control.mp3',
    'assessment': 'startassessment.mp3',
    'quickAccess': 'quickorguidedassessment.mp3',
    'mic': 'homescreen_voice_control.mp3',
    'aiSummary': 'summary.mp3',
    'ayurveda': 'ayurvedmode.mp3',
  };

  static void playAudio(GlobalKey key, Map<GlobalKey, String> keyMap) {
    final logicalName = keyMap[key];
    if (logicalName == null) return;

    final isHindi = LanguageController.instance.currentLanguageCode == 'hi';
    final fileName = isHindi ? _hindiAudio[logicalName] : _englishAudio[logicalName];

    if (fileName != null) {
      AudioService.instance.playVoiceHelp(fileName);
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1st Showcase: Voice Help Toggle, 2nd Showcase: Assessment Card
  final GlobalKey _voiceHelpToggleKey = GlobalKey();
  final GlobalKey _assessmentKey = GlobalKey();
  final GlobalKey _quickAccessKey = GlobalKey();
  final GlobalKey _micKey = GlobalKey();
  final GlobalKey _ayurvedaNavKey = GlobalKey();
  final GlobalKey _aiSummaryNavKey = GlobalKey();

  late final Map<GlobalKey, String> _showcaseAudioKeyMap = {
    _voiceHelpToggleKey: 'voiceHelpToggle',
    _assessmentKey: 'assessment',
    _quickAccessKey: 'quickAccess',
    _micKey: 'mic',
    _ayurvedaNavKey: 'ayurveda',
    _aiSummaryNavKey: 'aiSummary',
  };

  List<GlobalKey> get _showcaseKeys => [
    _voiceHelpToggleKey,
    _assessmentKey,
    _quickAccessKey,
    _micKey,
    _ayurvedaNavKey,
    _aiSummaryNavKey,
  ];

  List<_InfoCardData> get _infoCards => [
    _InfoCardData(
      icon: LucideIcons.brain,
      badge: '70–80%',
      title: tr('info_card_1_title'),
      subtitle: tr('info_card_1_sub'),
    ),
    _InfoCardData(
      icon: LucideIcons.clock,
      badge: '2–5 min',
      title: tr('info_card_2_title'),
      subtitle: tr('info_card_2_sub'),
    ),
    _InfoCardData(
      icon: LucideIcons.leaf,
      badge: 'Prakriti · Vikriti · Agni',
      title: tr('info_card_3_title'),
      subtitle: tr('info_card_3_sub'),
    ),
    _InfoCardData(
      icon: LucideIcons.shield_check,
      badge: 'ABHA linked',
      title: tr('info_card_4_title'),
      subtitle: tr('info_card_4_sub'),
    ),
  ];

  late final PageController _carouselController = PageController(viewportFraction: 0.88);
  Timer? _carouselAutoPlayTimer;

  bool _showTutorialReminder = false;
  bool _showcaseStarted = false;
  bool _isProfileIncomplete = false;
  bool _isEmergencyActive = false;
  bool _voiceHelpEnabled = false;

  String _patientName = 'Ramesh Chandra Sharma';
  String _phoneNumber = '+91 98214 40219';

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _showTutorialReminder = !(LocalStorageService.isHomeTutorialShown());
    _initNotifications();
    _loadProfile();
    _startCarouselAutoPlay();
  }

  Future<void> _initNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    try {
      await _notifications.initialize(settings: settings);
    } catch (_) {}
  }

  void _loadProfile() {
    final profile = LocalStorageService.getPatientProfile();

    if (profile != null && profile.isNotEmpty) {
      setState(() {
        _patientName = profile['fullName'] ?? _patientName;
        _phoneNumber = profile['phoneNumber'] ?? _phoneNumber;
        _isProfileIncomplete = profile['dietaryPreference'] == null || profile['lifestyleSurveyDone'] != true;
      });
    } else {
      setState(() {
        _isProfileIncomplete = true;
      });
    }
  }

  void _go(String route) => Navigator.pushNamed(context, route);

  void _dismissTutorial() {
    setState(() => _showTutorialReminder = false);
    LocalStorageService.setHomeTutorialShown(true);
  }

  void _dismissProfileReminder() => setState(() => _isProfileIncomplete = false);
  void _dismissEmergency() => setState(() => _isEmergencyActive = false);

  void _startCarouselAutoPlay() {
    _carouselAutoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_carouselController.hasClients) return;
      final current = _carouselController.page?.round() ?? _carouselController.initialPage;
      final next = current + 1 >= _infoCards.length ? 0 : current + 1;

      _carouselController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final fg = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textSecondary;

    return ShowCaseWidget(
      onStart: (index, key) => HomeShowcaseManager.playAudio(key, _showcaseAudioKeyMap),
      onComplete: (int? index, GlobalKey<State<StatefulWidget>> key) {
        LocalStorageService.setHomeTutorialShown(true);
        if (mounted) {
          setState(() {
            _showTutorialReminder = false;
            _showcaseStarted = false;
          });
        }
      },
      builder: (scopedContext) {
        if (!_showcaseStarted && !LocalStorageService.isHomeTutorialShown()) {
          _showcaseStarted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ShowCaseWidget.of(scopedContext).startShowCase(_showcaseKeys);
          });
        }
        return Scaffold(
          backgroundColor: bg,
          extendBody: true,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Transform.translate(
            offset: const Offset(0, -19),
            child: Showcase(
              key: _micKey,
              title: tr('showcase_mic_title'),
              description: tr('showcase_mic_desc'),
              child: _buildLargeMicButton(isDark),
            ),
          ),
          bottomNavigationBar: _buildCurvedBottomNavigation(isDark, fg, muted),
          body: SafeArea(
            bottom: false,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 130),
              children: [
                _buildIdentityRow(isDark, fg, muted),
                const SizedBox(height: 18),
                Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),
                const SizedBox(height: 20),
                if (_buildReminder(isDark, fg, muted) != null) ...[
                  _buildReminder(isDark, fg, muted)!,
                  const SizedBox(height: 22),
                ],
                _buildWelcomeSection(isDark, fg, muted),
                const SizedBox(height: 18),
                _buildHeroPoster(isDark, fg, muted),
                const SizedBox(height: 22),
                _buildInfoCarousel(isDark, fg, muted),
                const SizedBox(height: 10),
                _buildCarouselDots(isDark),
                const SizedBox(height: 22),
                _buildSecondaryActions(isDark, fg, muted),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIdentityRow(bool isDark, Color fg, Color muted) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(40),
                onTap: () => _go(AppRoutes.profile),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? const Color(0xFF132F6E) : AppColors.primaryContainer,
                  ),
                  child: ClipOval(
                    child: Lottie.asset(
                      'assets/lottie/patient_avatar.json',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        LucideIcons.user,
                        color: isDark ? AppColors.highlight : AppColors.primary,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: InkWell(
                  onTap: () => _go(AppRoutes.profile),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Textbasepo(
                        _patientName,
                        max: 1,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                      const SizedBox(height: 2),
                      Textbasepo(
                        _phoneNumber,
                        max: 1,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: muted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Showcase(
          key: _voiceHelpToggleKey,
          title: 'Voice Assistance Help',
          description: 'Toggle audio guide helper on or off',
          child: _buildVoiceToggle(isDark, fg),
        ),
      ],
    );
  }

  Widget _buildVoiceToggle(bool isDark, Color fg) {
    return GestureDetector(
      onTap: () => setState(() => _voiceHelpEnabled = !_voiceHelpEnabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: 62,
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: _voiceHelpEnabled
              ? AppColors.primary
              : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.05)),
          border: Border.all(
            color: _voiceHelpEnabled ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.border),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: _voiceHelpEnabled ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 7, offset: const Offset(0, 2)),
                  ],
                ),
                child: Icon(
                  _voiceHelpEnabled ? LucideIcons.mic : LucideIcons.mic_off,
                  size: 13,
                  color: _voiceHelpEnabled ? AppColors.primary : fg.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(bool isDark, Color fg, Color muted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Textbasepo(tr('namaste'), fontSize: 20, fontWeight: FontWeight.w600, color: fg),
            const SizedBox(width: 6),
            Textbasepo(_patientName.split(' ').first, fontSize: 20, fontWeight: FontWeight.w800, color: fg),
          ],
        ),
        const SizedBox(height: 4),
        Textbasepo(
          tr('health_in_hands'),
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
        Textbasepo(
          tr('explore_health_desc'),
          fontSize: 14,
          color: muted,
        ),
      ],
    );
  }

  Widget _buildHeroPoster(bool isDark, Color fg, Color muted) {
    return Showcase(
      key: _assessmentKey,
      title: tr('showcase_assessment_title'),
      description: tr('showcase_assessment_desc'),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: isDark ? [const Color(0xFF1A237E), const Color(0xFF0D47A1)] : [AppColors.primary, const Color(0xFF448AFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => _go(AppRoutes.startAssessment),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(LucideIcons.activity, size: 150, color: Colors.white.withValues(alpha: 0.15)),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Textbasepo(
                          'AYUSH EVALUATION',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Textbasepo(
                        'Start Assessment',
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 180,
                        child: Textbasepo(
                          tr('start_assessment_sub'),
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Textbasepo(tr('BEGIN'), fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                          const SizedBox(width: 8),
                          const Icon(LucideIcons.chevron_right, size: 18, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCarousel(bool isDark, Color fg, Color muted) {
    return SizedBox(
      height: 142,
      child: PageView.builder(
        controller: _carouselController,
        itemCount: _infoCards.length,
        itemBuilder: (context, i) {
          final card = _infoCards[i];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 14, offset: const Offset(0, 6)),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.1)),
                    child: Icon(card.icon, size: 20, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Textbasepo(
                          card.badge,
                          max: 1,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                        const SizedBox(height: 4),
                        Textbasepo(
                          card.title,
                          max: 1,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                        const SizedBox(height: 4),
                        Textbasepo(
                          card.subtitle,
                          max: 3,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 12,
                          color: muted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCarouselDots(bool isDark) {
    return AnimatedBuilder(
      animation: _carouselController,
      builder: (context, _) {
        double page = 0;
        if (_carouselController.hasClients && _carouselController.page != null) {
          page = _carouselController.page!;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_infoCards.length, (i) {
            final isActive = (page.round() == i);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isActive ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.border),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSecondaryActions(bool isDark, Color fg, Color muted) {
    final items = [
      (tr('ai_summary_title'), 'assets/lottie/ai_summary.json', LucideIcons.sparkles, AppRoutes.aiSummary, const Color(0xFF6366F1)),
      (tr('upload_document'), 'assets/lottie/upload_document.json', LucideIcons.file_up, AppRoutes.uploadDocument, const Color(0xFF10B981)),
      (tr('family_members_title'), 'assets/lottie/family.json', LucideIcons.users, AppRoutes.addFamilyMember, const Color(0xFFF59E0B)),
    ];

    return Showcase(
      key: _quickAccessKey,
      title: tr('showcase_quick_title'),
      enableAutoScroll: true,
      description: tr('showcase_quick_desc'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Textbasepo(tr('quick_access'), fontSize: 22, fontWeight: FontWeight.w700, color: fg),
          const SizedBox(height: 16),
          Row(
            children: items.map((item) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: InkWell(
                    onTap: () => _go(item.$4),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border.withValues(alpha: 0.6)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(color: item.$5.withValues(alpha: 0.1), shape: BoxShape.circle),
                            padding: const EdgeInsets.all(12),
                            child: Lottie.asset(
                              item.$2,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(item.$3, color: item.$5, size: 24),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Textbasepo(
                            item.$1,
                            textAlign: TextAlign.center,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: fg,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget? _buildReminder(bool isDark, Color fg, Color muted) {
    if (_isEmergencyActive) {
      return _reminderRow(
        isDark: isDark,
        fg: fg,
        muted: muted,
        color: AppColors.error,
        lottieAsset: 'assets/lottie/emergency_alert.json',
        fallbackIcon: LucideIcons.bell,
        title: tr('home_reminder_emergency_title'),
        subtitle: tr('home_reminder_emergency_desc'),
        onDismiss: _dismissEmergency,
        actionLabel: tr('call_staff'),
        onAction: () {},
      );
    }
    if (_isProfileIncomplete) {
      return _reminderRow(
        isDark: isDark,
        fg: fg,
        muted: muted,
        color: AppColors.warning,
        lottieAsset: 'assets/lottie/profile_reminder.json',
        fallbackIcon: LucideIcons.triangle_alert,
        title: tr('home_reminder_incomplete_profile_title'),
        subtitle: tr('home_reminder_incomplete_profile_desc'),
        onDismiss: _dismissProfileReminder,
        actionLabel: tr('complete_now'),
        onAction: () => _go(AppRoutes.completeProfile),
      );
    }
    if (_showTutorialReminder) {
      return _reminderRow(
        isDark: isDark,
        fg: fg,
        muted: muted,
        color: AppColors.secondary,
        lottieAsset: 'assets/lottie/welcome_guide.json',
        fallbackIcon: LucideIcons.sparkles,
        title: tr('home_reminder_tutorial_title'),
        subtitle: tr('home_reminder_tutorial_desc'),
        onDismiss: _dismissTutorial,
        actionLabel: 'View guide',
        onAction: () {
          setState(() {
            _showTutorialReminder = false;
            _showcaseStarted = true;
          });
        },
      );
    }
    return null;
  }

  Widget _reminderRow({
    required bool isDark,
    required Color fg,
    required Color muted,
    required Color color,
    required String lottieAsset,
    required IconData fallbackIcon,
    required String title,
    required String subtitle,
    required VoidCallback onDismiss,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 13),
      decoration: BoxDecoration(border: Border(left: BorderSide(color: color, width: 3))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.1)),
            child: Lottie.asset(
              lottieAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: color, size: 19),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Textbasepo(title, fontSize: 16, fontWeight: FontWeight.w700, color: fg),
                const SizedBox(height: 3),
                Textbasepo(subtitle, fontSize: 12, color: muted),
                if (actionLabel != null) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: onAction,
                    child: Textbasepo(actionLabel, fontSize: 13, color: color, fontWeight: FontWeight.w800),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(LucideIcons.x, size: 17, color: muted),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }

  Widget _buildLargeMicButton(bool isDark) {
    return Container(
      width: 82,
      height: 82,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? AppColors.backgroundDark : AppColors.background),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent,
          boxShadow: [
            BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 22, offset: const Offset(0, 7)),
          ],
        ),
        child: Center(
          child: VoiceControlButton(
            contextHint: 'Speak in any Indian language or ask AYUSH queries',
            onTextCaptured: (text) {},
          ),
        ),
      ),
    );
  }

  Widget _buildCurvedBottomNavigation(bool isDark, Color fg, Color muted) {
    return Transform.translate(
      offset: const Offset(0, -32),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        height: 76,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08), blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Expanded(
                child: Showcase(
                  key: _ayurvedaNavKey,
                  title: tr('showcase_ayurveda_mode_title') ?? 'Ayurveda Mode',
                  description: tr('showcase_ayurveda_mode_desc') ?? 'Switch to specialized evaluation mode',
                  child: _curvedNavItem(
                    lottieAsset: 'assets/lottie/ayurveda_leaf.json',
                    fallbackIcon: LucideIcons.sprout,
                    label: tr('ayurvaid_mode'),
                    color: muted,
                    onTap: () => _go(AppRoutes.startAssessment),
                    iconSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: 76),
              Expanded(
                child: Showcase(
                  key: _aiSummaryNavKey,
                  title: tr('showcase_ai_summary_title') ?? 'AI Summary',
                  description: tr('showcase_ai_summary_desc') ?? 'View aggregated health reports instantly',
                  child: _curvedNavItem(
                    lottieAsset: 'assets/lottie/ai_summary_nav.json',
                    fallbackIcon: LucideIcons.sparkles,
                    label: tr('ai_summary_title'),
                    color: muted,
                    onTap: () => _go(AppRoutes.aiSummary),
                    iconSize: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _curvedNavItem({
    required String lottieAsset,
    required IconData fallbackIcon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required double iconSize,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 25,
              height: 25,
              child: Lottie.asset(
                lottieAsset,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(fallbackIcon, size: iconSize, color: color),
              ),
            ),
            const SizedBox(height: 3),
            Textbasepo(
              label,
              max: 1,
              overflow: TextOverflow.ellipsis,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _carouselAutoPlayTimer?.cancel();
    _carouselController.dispose();
    super.dispose();
  }
}