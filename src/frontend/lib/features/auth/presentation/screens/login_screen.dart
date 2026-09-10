import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sih/app/theme/app_text_styles.dart';
import 'package:sih/features/auth/presentation/screens/qr_Scan.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/services/Otplocalization.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/constants/app_strings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/services/audio_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _currentIndex = 0;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _rationController = TextEditingController();
  final TextEditingController _abhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final lastTabStr = LocalStorageService.getString(LocalStorageService.keyLastLoginTab) ?? '0';
    final initialIndex = int.tryParse(lastTabStr) ?? 0;
    _currentIndex = (initialIndex >= 0 && initialIndex < 4) ? initialIndex : 0;
    _playAudioForTab(_currentIndex);
  }

  void _playAudioForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        AudioService.instance.playVoiceHelp('mobile_number.mp3');
        break;
      case 1:
        AudioService.instance.playVoiceHelp('adhar_number.mp3');
        break;
      case 2:
        AudioService.instance.playVoiceHelp('abha_id.mp3');
        break;
      case 3:
        AudioService.instance.playVoiceHelp('RationID.mp3');
        break;
      default:
        AudioService.instance.playVoiceHelp('mobile_number.mp3');
        break;
    }
  }

  void _playVoiceHelp() {
    _playAudioForTab(_currentIndex);
  }

  void _setTab(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      LocalStorageService.saveString(
        LocalStorageService.keyLastLoginTab,
        index.toString(),
      );
      _playAudioForTab(index);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _aadharController.dispose();
    _rationController.dispose();
    _abhaController.dispose();
    super.dispose();
  }

  Future<void> _navigateToOtp() async {
    if (_currentIndex == 0) {
      final phoneText = _phoneController.text.trim();
      final phoneRegex = RegExp(r'^[6-9]\d{9}$');

      if (!phoneRegex.hasMatch(phoneText)) {
        _showError(tr('err_invalid_phone'));
        return;
      }
    } else if (_currentIndex == 1 && _aadharController.text.length < 12) {
      _showError(tr('err_invalid_id'));
      return;
    } else if (_currentIndex == 2 && _abhaController.text.isEmpty) {
      _showError(tr('err_enter_abha'));
      return;
    } else if (_currentIndex == 3 && _rationController.text.isEmpty) {
      _showError(tr('err_enter_ration'));
      return;
    }

    // Save login context method to local storage so CompleteProfileScreen knows if it was a phone login
    await LocalStorageService.saveString('login_method', _currentIndex == 0 ? 'phone' : 'other');

    await OtpService.generateAndSendOtp();

    if (mounted) {
      Navigator.pushNamed(context, AppRoutes.otp);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Textbasepo(message, color: Colors.white),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _parseAndSaveAadhaarData(String rawPayload) {
    try {
      String extractAttr(String attrName) {
        final regExp = RegExp('$attrName="([^"]*)"');
        final match = regExp.firstMatch(rawPayload);
        return match != null && match.group(1) != null ? match.group(1)! : '';
      }

      final String uid = extractAttr('uid');
      final String name = extractAttr('name') ?? extractAttr('n');
      final String dob = extractAttr('dob') ?? extractAttr('d');
      final String gender = extractAttr('gender') ?? extractAttr('g');
      final String phone = extractAttr('mbl') ?? extractAttr('phone');

      final String co = extractAttr('co');
      final String house = extractAttr('house');
      final String street = extractAttr('street');
      final String vtc = extractAttr('vtc');
      final String dist = extractAttr('dist');
      final String state = extractAttr('state');
      final String pc = extractAttr('pc');

      String cleanId = uid;
      if (cleanId.isEmpty) {
        String cleaned = rawPayload.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleaned.length >= 12) {
          cleanId = cleaned.substring(cleaned.length - 12);
        } else {
          cleanId = rawPayload;
        }
      }

      final String fullAddress = [co, house, street, vtc, dist, state, pc]
          .where((element) => element.isNotEmpty)
          .join(', ');

      setState(() {
        _aadharController.text = cleanId;
        if (phone.isNotEmpty) {
          _phoneController.text = phone;
        }
      });

      final profileData = {
        'fullName': name,
        'dob': dob,
        'gender': gender == 'M' ? 'Male' : (gender == 'F' ? 'Female' : 'Other'),
        'phone': phone,
        'address': fullAddress,
        'idNumber': cleanId,
        'rawPayload': rawPayload,
      };

      LocalStorageService.setPatientProfile(profileData);
    } catch (e) {
      setState(() {
        _aadharController.text = rawPayload;
      });
    }
  }

  Future<void> _onScanAadharQr() async {
    final String? scannedData = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const AadhaarScannerScreen(),
      ),
    );

    if (scannedData != null && scannedData.isNotEmpty) {
      _parseAndSaveAadhaarData(scannedData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Textbasepo(tr('aadhaar_scanned_success'), color: Colors.white),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
      );

      if (result != null && result.isNotEmpty) {
        String fileName = result.first.name;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Textbasepo(tr('file_selected', args: {'file': fileName}), color: Colors.white),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Textbasepo(tr('err_file_pick'), color: Colors.white),
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getCurrentAssetPath() {
    switch (_currentIndex) {
      case 0: return 'assets/images/mobile.png';
      case 1: return 'assets/images/aadhaar.png';
      case 2: return 'assets/images/abha.png';
      case 3: return 'assets/images/ration.png';
      default: return 'assets/images/mobile.png';
    }
  }

  String _getTabName(int index) {
    switch (index) {
      case 0: return tr('tab_phone') ?? 'Phone';
      case 1: return tr('tab_aadhar') ?? 'ID';
      case 2: return tr('tab_abha') ?? 'ABHA';
      case 3: return tr('tab_ration') ?? 'Ration';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A), size: 20),
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
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: SizedBox(
                                key: ValueKey<int>(_currentIndex),
                                width: 250,
                                height: 250,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Image.asset(
                                    _getCurrentAssetPath(),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blueAccent.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          LucideIcons.image,
                                          size: 44,
                                          color: Colors.blueAccent,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(24, 30, 24, 10),
                          height: 48,
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Row(
                            children: List.generate(4, (index) {
                              final isSelected = _currentIndex == index;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => _setTab(index),
                                  behavior: HitTestBehavior.opaque,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOutCubic,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isDark ? const Color(0xFF334155) : Colors.white)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: Textbasepo(
                                        _getTabName(index),
                                        color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        fontSize: 13,
                                        overflow: TextOverflow.ellipsis,
                                        max: 1,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.03),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                                  blurRadius: 24,
                                  offset: const Offset(0, -8),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(28, 28, 28, MediaQuery.of(context).viewInsets.bottom + 24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildCurrentForm(isDark, const Color(0xFF0F172A), const Color(0xFF64748B)),
                                  ],
                                ),
                              ),
                            ),
                          ),
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

  Widget _buildCurrentForm(bool isDark, Color textColor, Color subTextColor) {
    switch (_currentIndex) {
      case 0: return _buildPhoneTab(isDark, textColor, subTextColor);
      case 1: return _buildAadharTab(isDark, textColor, subTextColor);
      case 2: return _buildAbhaTab(isDark, textColor, subTextColor);
      case 3: return _buildRationTab(isDark, textColor, subTextColor);
      default: return const SizedBox.shrink();
    }
  }

  InputDecoration _buildSeamlessInput(bool isDark, Color textColor, String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: textColor.withValues(alpha: 0.35), fontSize: 15),
      prefixIcon: Icon(icon, color: textColor.withValues(alpha: 0.6), size: 20),
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: textColor.withValues(alpha: 0.25), width: 1.5)),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required VoidCallback onPressed, required bool isDark, required Color textColor}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Textbasepo(label, fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildPhoneTab(bool isDark, Color textColor, Color subTextColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Textbasepo(tr('phone_label') ?? 'Mobile Login', fontSize: 26, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5),
        const SizedBox(height: 4),
        Textbasepo(tr('phone_label_sub') ?? 'Enter your mobile number to receive a secure login code.', fontSize: 13, color: subTextColor, height: 1.4),
        const SizedBox(height: 28),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.w600),
          decoration: _buildSeamlessInput(isDark, textColor, '***********', LucideIcons.smartphone).copyWith(
            counterText: "",
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 18, right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.smartphone, color: textColor.withValues(alpha: 0.6), size: 20),
                  const SizedBox(width: 10),
                  Textbasepo('+91', fontWeight: FontWeight.bold, color: textColor, fontSize: 15),
                  const SizedBox(width: 10),
                  Container(width: 1, height: 20, color: textColor.withValues(alpha: 0.15)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildActionButton(label: tr('send_otp') ?? 'Continue', icon: LucideIcons.arrow_right, onPressed: _navigateToOtp, isDark: isDark, textColor: textColor),
      ],
    );
  }

  Widget _buildAadharTab(bool isDark, Color textColor, Color subTextColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Textbasepo(tr('aadhar_label') ?? 'ID Verification', fontSize: 26, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5),
            ),
            IconButton(
              onPressed: _onScanAadharQr,
              icon: const Icon(LucideIcons.qr_code, size: 20),
              color: textColor,
              style: IconButton.styleFrom(backgroundColor: textColor.withValues(alpha: 0.06), padding: const EdgeInsets.all(10)),
            )
          ],
        ),
        const SizedBox(height: 5),
        Textbasepo(tr('aadhaar_label_sub') ?? 'Use your ID number or scan the QR code to proceed.', fontSize: 13, color: subTextColor, height: 1.4),
        const SizedBox(height: 28),
        TextField(
          controller: _aadharController,
          keyboardType: TextInputType.number,
          maxLength: 12,
          style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.w600),
          decoration: _buildSeamlessInput(isDark, textColor, 'XXXX XXXX XXXX', LucideIcons.badge_check).copyWith(counterText: ""),
        ),
        const SizedBox(height: 24),
        _buildActionButton(label: tr('proceed') ?? 'Verify ID', icon: LucideIcons.shield_check, onPressed: _navigateToOtp, isDark: isDark, textColor: textColor),
        const SizedBox(height: 12),
        Center(child: Textbasepo(tr('or') ?? 'OR', fontWeight: FontWeight.w400, color: Colors.black45)),
        const SizedBox(height: 12),
        Center(child: GestureDetector(onTap: _pickDocument, child: Textbasepo(tr('upload_doc') ?? 'Upload Document', fontWeight: FontWeight.w600, fontSize: 15, color: Colors.blueAccent))),
      ],
    );
  }

  Widget _buildAbhaTab(bool isDark, Color textColor, Color subTextColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Textbasepo(tr('abha_label') ?? 'ABHA Portal', fontSize: 26, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5),
        const SizedBox(height: 6),
        Textbasepo(tr('abha_label_sub'), fontSize: 13, color: subTextColor, height: 1.4),
        const SizedBox(height: 24),
        TextField(
          controller: _abhaController,
          keyboardType: TextInputType.text,
          style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.w600),
          decoration: _buildSeamlessInput(isDark, textColor, tr('Enter_id'), LucideIcons.shield_plus),
        ),
        const SizedBox(height: 20),
        _buildActionButton(label: tr('continue'), icon: LucideIcons.arrow_right, onPressed: _navigateToOtp, isDark: isDark, textColor: textColor),
        const SizedBox(height: 16),
        Center(child: Textbasepo('OR', fontWeight: FontWeight.w400, color: Colors.black45)),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: () async {
              final Uri url = Uri.parse(Applinks.abhaLink);
              try {
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              } catch (e) {}
            },
            child: Textbasepo(tr('abha_redirect'), fontWeight: FontWeight.w600, fontSize: 14, color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildRationTab(bool isDark, Color textColor, Color subTextColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Textbasepo(tr('ration_label') ?? 'Ration Card', fontSize: 26, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5),
        const SizedBox(height: 6),
        Textbasepo(tr('ration_label_sub'), fontSize: 13, color: subTextColor, height: 1.4),
        const SizedBox(height: 28),
        TextField(
          controller: _rationController,
          keyboardType: TextInputType.text,
          style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.w600),
          decoration: _buildSeamlessInput(isDark, textColor, 'e.g. RC-1029384756', LucideIcons.credit_card),
        ),
        const SizedBox(height: 24),
        _buildActionButton(label: tr('continue') ?? 'Verify Card', icon: LucideIcons.arrow_right, onPressed: _navigateToOtp, isDark: isDark, textColor: textColor),
      ],
    );
  }
}