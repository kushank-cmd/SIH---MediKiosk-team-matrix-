import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/services/Otplocalization.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/widgets/primary_button.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isPhoneLogin = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifyingOtp = false;

  Timer? _otpExpiryTimer;
  int _resendCountdown = 120;
  bool _canResend = false;
  bool _otpTriggered = false;

  DateTime? _selectedDate = DateTime(2004, 9, 1);
  String _selectedGender = 'Male';
  bool _isLoading = false;

  late final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();

    // Explicitly check login method saved from LoginScreen
    final loginMethod = LocalStorageService.getString('login_method') ?? '';
    _isPhoneLogin = loginMethod == 'phone';

    final profile = LocalStorageService.getPatientProfile();

    if (profile != null) {
      _nameController.text = profile['fullName'] ?? '';
      _dobController.text = profile['dob'] ?? '';
      _phoneController.text = profile['phone'] ?? '';
      _addressController.text = profile['address'] ?? '';

      String parsedGender = profile['gender'] ?? 'Male';
      if (_genders.contains(parsedGender)) {
        _selectedGender = parsedGender;
      }
    }

    _playIntroAudio();
  }

  int get _totalPages => _isPhoneLogin ? 3 : 4;

  void _playIntroAudio() {
    AudioService.instance.playVoiceHelp('full_legal_name.mp3');
  }

  void _playStepAudio(int stepIndex) {
    String file = 'full_legal_name.mp3';
    if (_isPhoneLogin) {
      if (stepIndex == 1) file = 'demographics.mp3';
      if (stepIndex == 2) file = 'address.mp3';
    } else {
      if (stepIndex == 1) file = 'demographics.mp3';
      if (stepIndex == 2) file = 'phoneotp.mp3';
      if (stepIndex == 3) file = 'address.mp3';
    }
    AudioService.instance.playVoiceHelp(file);
  }

  void _playVoiceHelp() {
    _playStepAudio(_currentPage);
  }

  void _startOtpTimer() {
    setState(() {
      _resendCountdown = 120;
      _canResend = false;
    });
    _otpExpiryTimer?.cancel();

    _otpExpiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    _otpExpiryTimer?.cancel();
    _pageController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    for (var c in _otpControllers) c.dispose();
    for (var f in _otpFocusNodes) f.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: tr('select_dob_help') ?? 'SELECT DATE OF BIRTH',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _nextPage() {
    int nextStep = _currentPage + 1;
    if (nextStep < _totalPages) {
      _playStepAudio(nextStep);
      _pageController.animateToPage(nextStep, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    } else {
      _onSaveAndContinue();
    }
  }

  void _previousPage() {
    int prevStep = _currentPage - 1;
    if (prevStep >= 0) {
      _playStepAudio(prevStep);
      _pageController.animateToPage(prevStep, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _onSaveAndContinue() async {
    setState(() { _isLoading = true; });

    final profileData = {
      'fullName': _nameController.text.trim(),
      'dob': _dobController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'gender': _selectedGender,
      'abhaId': '91-8723-9941-0023',
    };

    await LocalStorageService.setPatientProfile(profileData);

    if (mounted) {
      setState(() { _isLoading = false; });
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home,(route) => false);
    }
  }

  String _getStepAssetPath() {
    if (_isPhoneLogin) {
      switch (_currentPage) {
        case 0: return 'assets/images/name.png';
        case 1: return 'assets/images/dob.png';
        case 2: return 'assets/images/address.png';
        default: return 'assets/images/name.png';
      }
    } else {
      switch (_currentPage) {
        case 0: return 'assets/images/name.png';
        case 1: return 'assets/images/dob.png';
        case 2: return 'assets/images/phone.png';
        case 3: return 'assets/images/address.png';
        default: return 'assets/images/name.png';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = Responsive.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const textColor = Color(0xFF0F172A);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: AppColors.background),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: textColor, size: 20), onPressed: _previousPage),
                    GestureDetector(
                      onTap: _playVoiceHelp,
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.volume_up_outlined, color: textColor, size: 16),
                            const SizedBox(width: 6),
                            Textbasepo(tr('Voice') ?? 'Voice Help', fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  children: List.generate(_totalPages, (index) {
                    final bool isActive = index <= _currentPage;
                    return Expanded(
                      child: Container(
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(color: isActive ? AppColors.primary : AppColors.border, borderRadius: BorderRadius.circular(2)),
                      ),
                    );
                  }),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: SizedBox(
                      key: ValueKey<int>(_currentPage),
                      width: 140,
                      height: 140,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(70),
                        child: Image.asset(_getStepAssetPath(), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
                            child: const Center(child: Icon(Icons.check_circle_outline, size: 48, color: AppColors.primary)),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (int page) { setState(() { _currentPage = page; }); },
                  children: _isPhoneLogin
                      ? [
                    _buildStepName(isDark),
                    _buildStepDobGender(context, isDark, isTablet),
                    _buildStepAddress(isDark),
                  ]
                      : [
                    _buildStepName(isDark),
                    _buildStepDobGender(context, isDark, isTablet),
                    _buildStepPhoneAndOtpConditional(isDark),
                    _buildStepAddress(isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons({required String continueLabel, required VoidCallback onContinue, bool isLoading = false}) {
    return Row(
      children: [
        if (_currentPage > 0) ...[
          Expanded(
            child: SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _previousPage,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: Textbasepo(tr('back') ?? 'Back', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)), side: const BorderSide(color: AppColors.primary)),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: 2,
          child: PrimaryButton(label: continueLabel, isLoading: isLoading, leadingIcon: Icons.arrow_forward, onPressed: onContinue),
        ),
      ],
    );
  }

  Widget _buildStepName(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Textbasepo(tr('full_name') ?? 'What is your full name?', fontSize: 22, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            autofocus: true,
            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: tr('full_name_hint_simple') ?? 'Enter full name',
              prefixIcon: const Icon(Icons.person, color: AppColors.primary, size: 22),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 32),
          _buildActionButtons(
            continueLabel: tr('continue') ?? 'Continue',
            onContinue: () {
              if (_nameController.text.trim().isNotEmpty) {
                _nextPage();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Textbasepo(tr('name_alert') ?? 'Please enter your name')));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepDobGender(BuildContext context, bool isDark, bool isTablet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Textbasepo(tr('demographic') ?? 'Demographics', fontSize: 22, fontWeight: FontWeight.w800),
          const SizedBox(height: 24),
          _buildDobField(context, isDark),
          const SizedBox(height: 20),
          _buildGenderField(isDark),
          const SizedBox(height: 32),
          _buildActionButtons(continueLabel: tr('continue') ?? 'Continue', onContinue: _nextPage),
        ],
      ),
    );
  }

  Widget _buildStepPhoneAndOtpConditional(bool isDark) {
    bool isPhoneComplete = _phoneController.text.trim().length == 10;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Textbasepo(
            tr('phone_label') ?? 'Mobile Verification',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
          Textbasepo(
            tr('phone_number_sub') ?? 'Please enter your mobile number to receive a verification code.',
            fontSize: 14,
            color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            onChanged: (val) {
              setState(() {});
            },
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              counterText: "",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Textbasepo(
                  '+91',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              hintText: tr('phone_hint') ?? '10-digit mobile number',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // HIDDEN until phone number has exactly 10 digits
          if (isPhoneComplete) ...[
            Builder(
              builder: (context) {
                if (!_otpTriggered) {
                  _otpTriggered = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    OtpService.generateAndSendOtp();
                    _startOtpTimer();
                  });
                }
                return const SizedBox.shrink();
              },
            ),
            Textbasepo(
              tr('otp_title_ve') ?? 'Enter Verification Code',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 44,
                  height: 52,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _otpFocusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty && index < 5) {
                        _otpFocusNodes[index + 1].requestFocus();
                      } else if (val.isEmpty && index > 0) {
                        _otpFocusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
          ],

          const SizedBox(height: 24),
          _buildActionButtons(
            continueLabel: tr('continue') ?? 'Continue',
            isLoading: _isVerifyingOtp,
            onContinue: () {
              if (!isPhoneComplete) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      tr('phone_invalid_alert') ??
                          'Please enter a valid 10-digit mobile number.',
                    ),
                  ),
                );
                return;
              }

              final enteredOtp =
              _otpControllers.map((c) => c.text).join();
              final isValid = OtpService.verifyOtp(enteredOtp);

              if (!isValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      tr('otp_invalid_alert') ??
                          'Wrong or expired OTP. Please check or request a new one.',
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              setState(() {
                _isVerifyingOtp = true;
              });

              Future.delayed(const Duration(milliseconds: 600), () {
                if (mounted) {
                  setState(() {
                    _isVerifyingOtp = false;
                  });
                  _nextPage();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepAddress(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Textbasepo(tr('address') ?? 'Residential Address', fontSize: 22, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          const SizedBox(height: 24),
          TextField(
            controller: _addressController,
            maxLines: 4,
            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: tr('address_hint') ?? 'Street, village/town, district and pincode',
              prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 60), child: Icon(Icons.home, color: AppColors.primary, size: 22)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 32),
          _buildActionButtons(continueLabel: tr('save_continue') ?? 'Complete & Save', isLoading: _isLoading, onContinue: _onSaveAndContinue),
        ],
      ),
    );
  }

  Widget _buildDobField(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Textbasepo(tr('date_of_birth') ?? 'Date of Birth', fontSize: 14, fontWeight: FontWeight.w700),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _pickDateOfBirth(context),
          child: IgnorePointer(
            child: TextField(
              controller: _dobController,
              readOnly: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Textbasepo(tr('gender') ?? 'Gender', fontSize: 14, fontWeight: FontWeight.w700),
        const SizedBox(height: 6),
        Container(
          height: 52,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: _genders.map((gender) {
              final bool isSelected = _selectedGender == gender;
              return Expanded(
                child: InkWell(
                  onTap: () { setState(() { _selectedGender = gender; }); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: isSelected ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                    child: Textbasepo(gender, fontSize: 14, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? Colors.white : Colors.blue),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}