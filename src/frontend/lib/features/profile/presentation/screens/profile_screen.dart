import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../app/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    AudioService.instance.playVoiceHelp('profileview.mp3');
  }

  void _loadProfile() {
    setState(() {
      profile = LocalStorageService.getPatientProfile();
    });
  }

  void _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('logout_confirm_title')),
        content: Text(tr('logout_confirm_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(tr('logout')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await LocalStorageService.clearAll();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.languageSelection,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = profile?['fullName'] ?? 'User';
    final abha = profile?['abhaId'] ?? 'Not Linked';
    final phone = profile?['phone'] ?? 'Not Available';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white24,
                      child: Icon(LucideIcons.user, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'ABHA ID: $abha',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(tr('account_info')),
                  _buildInfoCard([
                    _buildInfoTile(LucideIcons.phone, tr('phone_label'), phone),
                    _buildInfoTile(LucideIcons.mail, tr('email'), profile?['email'] ?? 'Not set'),
                    _buildInfoTile(LucideIcons.map_pin, tr('address'), profile?['address'] ?? 'Not set'),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionTitle(tr('health_stats')),
                  _buildInfoCard([
                    _buildInfoTile(LucideIcons.droplets, tr('blood_group'), profile?['blood_group'] ?? 'Unknown'),
                    _buildInfoTile(LucideIcons.activity, tr('height_weight'), '${profile?['height'] ?? '--'} cm / ${profile?['weight'] ?? '--'} kg'),
                  ]),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: Icon(LucideIcons.log_out),
                      label: Text(tr('logout')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.red.shade100),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
