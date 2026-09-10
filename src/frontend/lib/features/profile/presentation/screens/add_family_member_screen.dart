import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_card.dart';

class FamilyMemberItem {
  final String id;
  final String name;
  final String relation;
  final String idNumber;
  final bool isVerified;
  final String age;

  FamilyMemberItem({
    required this.id,
    required this.name,
    required this.relation,
    required this.idNumber,
    required this.isVerified,
    required this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relation': relation,
      'idNumber': idNumber,
      'isVerified': isVerified,
      'age': age,
    };
  }

  factory FamilyMemberItem.fromMap(Map<String, dynamic> map) {
    return FamilyMemberItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      relation: map['relation']?.toString() ?? '',
      idNumber: map['idNumber']?.toString() ?? '',
      isVerified: map['isVerified'] == true,
      age: map['age']?.toString() ?? '',
    );
  }
}

class AddFamilyMemberScreen extends StatefulWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _selectedRelation = 'Spouse';
  final List<String> _relations = [
    'Spouse',
    'Child',
    'Parent',
    'Sibling',
    'Grandparent',
    'Other',
  ];

  List<FamilyMemberItem> _familyMembers = [];

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
    AudioService.instance.playVoiceHelp('familymember.mp3');
  }

  void _playVoiceHelp() {
    AudioService.instance.playVoiceHelp('familymember.mp3');
  }

  void _loadFamilyMembers() {
    final rawList = LocalStorageService.getFamilyMembers();
    if (rawList != null && rawList.isNotEmpty) {
      setState(() {
        _familyMembers = rawList.map((m) => FamilyMemberItem.fromMap(m)).toList();
      });
    }
  }

  Future<void> _persistMembers() async {
    await LocalStorageService.setFamilyMembers(_familyMembers.map((e) => e.toMap()).toList());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _onAddMember() {
    final String name = _nameController.text.trim();
    final String idNumber = _idController.text.trim();
    final String age = _ageController.text.trim().isNotEmpty
        ? '${_ageController.text.trim()} yrs'
        : 'Adult';

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('name_required_alert') ?? 'Please enter the family member full name.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _familyMembers.insert(
        0,
        FamilyMemberItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          relation: _selectedRelation,
          idNumber: idNumber.isNotEmpty ? idNumber : (tr('member_pending') ?? 'Pending'),
          isVerified: false,
          age: age,
        ),
      );
      _nameController.clear();
      _idController.clear();
      _ageController.clear();
    });

    _persistMembers();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('member_added_msg', args: {'name': name}) ?? '$name added to family group (Saved offline).'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removeMember(String id) {
    setState(() {
      _familyMembers.removeWhere((item) => item.id == id);
    });
    _persistMembers();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = Responsive.isTablet(context);
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
              tr('family_members_title'),
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tr('family_linked_badge', args: {'count': _familyMembers.length.toString()}) ?? '${_familyMembers.length} LINKED',
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark ? AppColors.highlight : AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _playVoiceHelp,
            icon: const Icon(LucideIcons.volume_2),
            tooltip: 'Voice Help',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('family_members_desc'),
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              // Form Card to Add Member
              SectionCard(
                title: tr('add_family_member'),
                subtitle: tr('add_member_help') ?? 'Link ABHA, Aadhar, or state health ID for dependent check-in',
                headerIcon: LucideIcons.user_plus,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isTablet)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildTextField(
                              isDark: isDark,
                              label: tr('full_name'),
                              hint: tr('full_name_hint') ?? 'e.g. Meera Sharma',
                              controller: _nameController,
                              icon: LucideIcons.user,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 2,
                            child: _buildRelationDropdown(isDark),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              isDark: isDark,
                              label: tr('age'),
                              hint: 'e.g. 28',
                              controller: _ageController,
                              icon: LucideIcons.calendar,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _buildTextField(
                        isDark: isDark,
                        label: tr('full_name'),
                        hint: tr('full_name_hint') ?? 'e.g. Meera Sharma',
                        controller: _nameController,
                        icon: LucideIcons.user,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(flex: 3, child: _buildRelationDropdown(isDark)),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              isDark: isDark,
                              label: tr('age'),
                              hint: 'e.g. 28',
                              controller: _ageController,
                              icon: LucideIcons.calendar,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),

                    // National / Health ID Number
                    _buildTextField(
                      isDark: isDark,
                      label: tr('member_id_label') ?? 'National ID / ABHA / Aadhar Number',
                      hint: tr('member_id_hint') ?? 'e.g. ABHA-14-Digit or Aadhar UID',
                      controller: _idController,
                      icon: LucideIcons.badge_info,
                    ),
                    const SizedBox(height: 20),

                    // Add Member Action Button
                    PrimaryButton(
                      label: tr('add_family_member'),
                      leadingIcon: LucideIcons.plus,
                      onPressed: _onAddMember,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Linked Members Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${tr('family_members_title')} (${_familyMembers.length})',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'NDHM Family Health Card',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // List of family members
              if (_familyMembers.isEmpty)
                SectionCard(
                  backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.users,
                            size: 36,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tr('no_family_linked') ?? 'No family members linked yet',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _familyMembers.length,
                  itemBuilder: (context, index) {
                    final member = _familyMembers[index];
                    return _buildMemberCard(member, isDark);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(FamilyMemberItem member, bool isDark) {
    return SectionCard(
      leftAccentColor: member.isVerified ? AppColors.primary : AppColors.secondary,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: member.isVerified
                  ? (isDark ? const Color(0xFF132F6E) : AppColors.primaryContainer)
                  : (isDark ? const Color(0xFF0F322B) : AppColors.secondaryContainer),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              LucideIcons.user,
              color: member.isVerified ? AppColors.primary : (isDark ? AppColors.highlight : AppColors.secondary),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Details with Expanded to avoid horizontal overflow
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.name,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${member.age}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      member.relation,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        member.idNumber,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Verification Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: member.isVerified
                  ? (isDark ? const Color(0xFF132F6E) : AppColors.primaryContainer.withValues(alpha: 0.6))
                  : (isDark ? const Color(0xFF0F322B) : AppColors.secondaryContainer),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: member.isVerified
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : (isDark ? AppColors.highlight.withValues(alpha: 0.3) : AppColors.secondary.withValues(alpha: 0.3)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  member.isVerified ? LucideIcons.circle_check : LucideIcons.clock,
                  size: 13,
                  color: member.isVerified ? AppColors.primary : (isDark ? AppColors.highlight : AppColors.secondary),
                ),
                const SizedBox(width: 4),
                Text(
                  tr(member.isVerified ? 'member_verified' : 'member_pending') ?? (member.isVerified ? 'Verified' : 'Pending'),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: member.isVerified ? AppColors.primary : (isDark ? AppColors.highlight : AppColors.secondary),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),

          // Delete button
          IconButton(
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            icon: Icon(
              LucideIcons.x,
              size: 18,
              color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
            ),
            tooltip: 'Remove',
            onPressed: () => _removeMember(member.id),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required bool isDark,
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
            ),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
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
      ],
    );
  }

  Widget _buildRelationDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('relationship'),
          style: AppTextStyles.labelMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRelation,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
              icon: Icon(
                LucideIcons.chevron_down,
                color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                size: 18,
              ),
              items: _relations.map((relation) {
                return DropdownMenuItem<String>(
                  value: relation,
                  child: Text(
                    tr('rel_${relation.toLowerCase()}') ?? relation,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedRelation = val;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}