import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/primary_button.dart';

class PatientItem {
  final String id;
  final String name;
  final String ageGender;
  final String token;
  final String lastVisitDate;
  final String primaryComplaint;
  final String doshaType;
  final String status;
  final Color statusColor;
  final Color statusBgColor;

  const PatientItem({
    required this.id,
    required this.name,
    required this.ageGender,
    required this.token,
    required this.lastVisitDate,
    required this.primaryComplaint,
    required this.doshaType,
    required this.status,
    required this.statusColor,
    required this.statusBgColor,
  });
}

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  bool _isLoading = false;
  bool _mockEmptyQueue = false;

  void _simulateRefresh() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _mockEmptyQueue = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Synchronized with ABDM Clinic Queue (6 Active Cases).'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  final List<PatientItem> _allPatients = const [
    PatientItem(
      id: 'P-101',
      name: 'Rajesh Patel',
      ageGender: '42M',
      token: '#201',
      lastVisitDate: 'Today, 09:30 AM',
      primaryComplaint: 'Amlapitta & Lower Back Stiffness',
      doshaType: 'Pitta-Vata',
      status: 'Ready for Review',
      statusColor: AppColors.primary,
      statusBgColor: Color(0xFFE8F5E9),
    ),
    PatientItem(
      id: 'P-102',
      name: 'Sunita Mehra',
      ageGender: '38F',
      token: '#202',
      lastVisitDate: 'Yesterday, 04:15 PM',
      primaryComplaint: 'Chronic Migraine (Ardhavabhedaka)',
      doshaType: 'Pitta-Pradhan',
      status: 'In Consultation',
      statusColor: AppColors.secondary,
      statusBgColor: Color(0xFFFFF3E0),
    ),
    PatientItem(
      id: 'P-103',
      name: 'Ananya Deshmukh',
      ageGender: '29F',
      token: '#203',
      lastVisitDate: '24 Aug 2026',
      primaryComplaint: 'Polycystic Ovarian Imbalance (Artava Kshaya)',
      doshaType: 'Kapha-Vata',
      status: 'AI Triage Complete',
      statusColor: Color(0xFF6B8AFD),
      statusBgColor: Color(0xFFEBF1FF),
    ),
    PatientItem(
      id: 'P-104',
      name: 'Vikramaditya Rao',
      ageGender: '56M',
      token: '#204',
      lastVisitDate: '18 Aug 2026',
      primaryComplaint: 'Knee Osteoarthritis (Sandhigata Vata)',
      doshaType: 'Vataja',
      status: 'Pending Review',
      statusColor: AppColors.error,
      statusBgColor: Color(0xFFFFEBEE),
    ),
    PatientItem(
      id: 'P-105',
      name: 'Pooja Verma',
      ageGender: '31F',
      token: '#205',
      lastVisitDate: '12 Aug 2026',
      primaryComplaint: 'Insomnia & Anxiety (Anidra/Chittodvega)',
      doshaType: 'Vata-Pitta',
      status: 'Follow-up Due',
      statusColor: AppColors.accent,
      statusBgColor: Color(0xFFF3E5F5),
    ),
    PatientItem(
      id: 'P-106',
      name: 'Harish Chandra',
      ageGender: '62M',
      token: '#206',
      lastVisitDate: '05 Aug 2026',
      primaryComplaint: 'Digestive Sluggishness & Medoroga',
      doshaType: 'Kaphaja',
      status: 'Completed',
      statusColor: Color(0xFF3B9B78),
      statusBgColor: Color(0xFFE8F5E9),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onPatientTapped(PatientItem patient) {
    Navigator.pushNamed(context, AppRoutes.aiPatientDoc);
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = Responsive.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredPatients = _mockEmptyQueue
        ? <PatientItem>[]
        : _allPatients.where((patient) {
            final query = _searchController.text.toLowerCase();
            final matchesSearch = patient.name.toLowerCase().contains(query) ||
                patient.primaryComplaint.toLowerCase().contains(query) ||
                patient.token.toLowerCase().contains(query);

            if (_selectedFilter == 'All') return matchesSearch;
            if (_selectedFilter == 'Pending') return matchesSearch && (patient.status.contains('Review') || patient.status.contains('Pending'));
            if (_selectedFilter == 'Completed') return matchesSearch && patient.status == 'Completed';
            return matchesSearch;
          }).toList();

    return AppScaffold(
      title: tr('patient_triage_list'),
      subtitle: 'OPD Queue and active AYUSH consultation cases',
      roleBadge: '${filteredPatients.length} PATIENTS',
      actions: [
        IconButton(
          icon: Icon(
            _mockEmptyQueue ? LucideIcons.eye_off : LucideIcons.eye,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          tooltip: _mockEmptyQueue ? 'Preview Populated Queue' : 'Preview Empty Queue State',
          onPressed: () {
            setState(() {
              _mockEmptyQueue = !_mockEmptyQueue;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _mockEmptyQueue
                      ? 'Simulating Empty OPD Queue placeholder state.'
                      : 'Restored active OPD queue data.',
                ),
                backgroundColor: AppColors.primary,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(LucideIcons.rotate_cw, color: isDark ? AppColors.highlight : AppColors.primary),
          tooltip: 'Refresh Queue',
          onPressed: _simulateRefresh,
        ),
      ],
      body: _isLoading
          ? const Center(
              child: LoadingIndicator(
                message: 'Synchronizing OPD queue with ABDM registry...',
                size: 44,
              ),
            )
          : Column(
              children: [
                // Search and Filter Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
                  child: Column(
                    children: [
                      // Search Input Field
                      TextField(
                        controller: _searchController,
                        style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search patient by name, token #, or condition...',
                          hintStyle: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                          prefixIcon: Icon(LucideIcons.search, color: isDark ? AppColors.highlight : AppColors.primary, size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(LucideIcons.x, size: 18, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Filter Chips Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', isDark),
                            const SizedBox(width: 8),
                            _buildFilterChip('Pending', isDark),
                            const SizedBox(width: 8),
                            _buildFilterChip('Completed', isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.border),

                // Patients Grid (Tablet) or List (Phone)
                Expanded(
                  child: filteredPatients.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    LucideIcons.users,
                                    size: 48,
                                    color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Patients In Consultation Queue',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'All registered patients have completed their AYUSH consultation, or no matches found for your filter criteria.',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                PrimaryButton(
                                  label: 'Reset Queue / Reload Data',
                                  leadingIcon: LucideIcons.rotate_cw,
                                  width: 260,
                                  onPressed: _simulateRefresh,
                                ),
                              ],
                            ),
                          ),
                        )
                      : isTablet
                          ? GridView.builder(
                              padding: const EdgeInsets.all(20.0),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 1.85,
                              ),
                              itemCount: filteredPatients.length,
                              itemBuilder: (context, index) {
                                final patient = filteredPatients[index];
                                return _buildPatientCard(patient, isDark);
                              },
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                              itemCount: filteredPatients.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final patient = filteredPatients[index];
                                return _buildPatientCard(patient, isDark);
                              },
                            ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final bool isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: isDark ? const Color(0xFF132F6E) : AppColors.primaryContainer,
      labelStyle: AppTextStyles.labelSmall.copyWith(
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
        if (val) setState(() => _selectedFilter = label);
      },
    );
  }

  Widget _buildPatientCard(PatientItem patient, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onPatientTapped(patient),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Token & Status Chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF132F6E) : AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          patient.token,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark ? AppColors.highlight : AppColors.primaryDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          patient.doshaType,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? patient.statusColor.withOpacity(0.2) : patient.statusBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      patient.status,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: patient.statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Patient Name & Age
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${patient.name} (${patient.ageGender})',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(LucideIcons.chevron_right, size: 16, color: isDark ? AppColors.highlight : AppColors.primary),
                ],
              ),
              const SizedBox(height: 4),

              // Chief Complaint
              Text(
                patient.primaryComplaint,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondary,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Last Visit Date
              Row(
                children: [
                  Icon(LucideIcons.clock, size: 13, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                  const SizedBox(width: 5),
                  Text(
                    'Last Visit: ${patient.lastVisitDate}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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
