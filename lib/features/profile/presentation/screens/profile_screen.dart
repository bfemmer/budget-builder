import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_viewmodel.dart';
import '../../data/models/profile_model.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dutyStationController;
  late TextEditingController _dobController;
  late TextEditingController _emailController;

  String _selectedRank = 'Senior Airman (E-4)';
  String _selectedGender = 'Female';
  String _selectedFamilySize = 'Single with no children/dependents';

  static const List<String> _usafRanks = [
    'Airman Basic (E-1)',
    'Airman (E-2)',
    'Airman First Class (E-3)',
    'Senior Airman (E-4)',
    'Staff Sergeant (E-5)',
    'Technical Sergeant (E-6)',
    'Master Sergeant (E-7)',
    'Senior Master Sergeant (E-8)',
    'Chief Master Sergeant (E-9)',
    '2nd Lieutenant (O-1)',
    '1st Lieutenant (O-2)',
    'Captain (O-3)',
    'Major (O-4)',
    'Lieutenant Colonel (O-5)',
    'Colonel (O-6)',
    'General Officer',
    'Civilian / Family Member',
  ];

  static const List<String> _genders = [
    'Female',
    'Male',
    'Non-Binary',
    'Prefer not to say',
  ];

  static const List<String> _familySizes = [
    'Single with no children/dependents',
    'Single with children/dependents',
    'Married with no children/dependents',
    'Married with children/dependents',
  ];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _dutyStationController = TextEditingController();
    _dobController = TextEditingController();
    _emailController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    final vm = Provider.of<ProfileViewModel>(context, listen: false);
    await vm.loadProfile();
    if (vm.profile != null) {
      final p = vm.profile!;
      _firstNameController.text = p.firstName;
      _lastNameController.text = p.lastName;
      _dutyStationController.text = p.dutyStation;
      _dobController.text = p.dateOfBirth;
      _emailController.text = p.email;

      if (_usafRanks.contains(p.rank)) _selectedRank = p.rank;
      if (_genders.contains(p.gender)) _selectedGender = p.gender;
      if (_familySizes.contains(p.familySize)) {
        _selectedFamilySize = p.familySize;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dutyStationController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime initial =
        DateTime.tryParse(_dobController.text) ?? DateTime(1995, 6, 29);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = Provider.of<ProfileViewModel>(context, listen: false);
    final updated = ProfileModel(
      id: vm.profile?.id ?? 1,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      rank: _selectedRank,
      dutyStation: _dutyStationController.text.trim(),
      gender: _selectedGender,
      dateOfBirth: _dobController.text.trim(),
      familySize: _selectedFamilySize,
      email: _emailController.text.trim(),
    );

    final success = await vm.updateProfile(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Profile updated successfully!' : 'Error saving profile.',
          ),
          backgroundColor: success
              ? AppColors.statusGreen
              : AppColors.statusRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.usafGold),
            onPressed: _saveProfile,
            tooltip: 'Save Profile',
          ),
        ],
      ),
      body: vm.isLoading && vm.profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Banner
                    Builder(
                      builder: (context) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [AppColors.airForceBlue, AppColors.navyCard]
                                  : [AppColors.airForceBlue, const Color(0xFF0F2A4A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppColors.cardBorder : AppColors.accentBlue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.accentBlue.withValues(
                                    alpha: 0.2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.military_tech,
                                  size: 36,
                                  color: AppColors.usafGold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vm.profile?.fullName.isNotEmpty == true
                                          ? vm.profile!.fullName
                                          : 'Airman Profile',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _selectedRank,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.usafGold,
                                      ),
                                    ),
                                    Text(
                                      _dutyStationController.text.isNotEmpty
                                          ? _dutyStationController.text
                                          : 'USAF Base / Unit',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // App Appearance Theme Card
                    const Text(
                      'APP APPEARANCE & THEME',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentBlue,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Consumer<ThemeViewModel>(
                      builder: (context, themeVm, child) {
                        final theme = Theme.of(context);
                        final textSecondary = theme.colorScheme.onSurface.withValues(alpha: 0.65);
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.brightness == Brightness.dark
                                  ? AppColors.cardBorder
                                  : AppColors.lightCardBorder,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Color Theme',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Select light or dark appearance. Saved persistently to device.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ChoiceChip(
                                      avatar: const Icon(Icons.dark_mode, size: 16),
                                      label: const Center(child: Text('Dark')),
                                      selected: themeVm.themeMode == ThemeMode.dark,
                                      selectedColor: AppColors.accentBlue.withValues(alpha: 0.3),
                                      onSelected: (selected) {
                                        if (selected) {
                                          themeVm.setThemeMode(ThemeMode.dark);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ChoiceChip(
                                      avatar: const Icon(Icons.light_mode, size: 16),
                                      label: const Center(child: Text('Light')),
                                      selected: themeVm.themeMode == ThemeMode.light,
                                      selectedColor: AppColors.accentBlue.withValues(alpha: 0.3),
                                      onSelected: (selected) {
                                        if (selected) {
                                          themeVm.setThemeMode(ThemeMode.light);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ChoiceChip(
                                      avatar: const Icon(Icons.settings_suggest, size: 16),
                                      label: const Center(child: Text('System')),
                                      selected: themeVm.themeMode == ThemeMode.system,
                                      selectedColor: AppColors.accentBlue.withValues(alpha: 0.3),
                                      onSelected: (selected) {
                                        if (selected) {
                                          themeVm.setThemeMode(ThemeMode.system);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'PERSONAL DETAILS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentBlue,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                            ),
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                            ),
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: _usafRanks.contains(_selectedRank)
                          ? _selectedRank
                          : _usafRanks.first,
                      decoration: const InputDecoration(
                        labelText: 'Rank / Paygrade',
                      ),
                      dropdownColor: Theme.of(context).cardTheme.color,
                      items: _usafRanks.map((rank) {
                        return DropdownMenuItem(
                          value: rank,
                          child: Text(
                            rank,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRank = val);
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _dutyStationController,
                      decoration: const InputDecoration(
                        labelText: 'Duty Station / Base',
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _genders.contains(_selectedGender)
                                ? _selectedGender
                                : _genders.first,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                            ),
                            dropdownColor: Theme.of(context).cardTheme.color,
                            items: _genders.map((g) {
                              return DropdownMenuItem(
                                value: g,
                                child: Text(
                                  g,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedGender = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _dobController,
                            readOnly: true,
                            onTap: _selectDate,
                            decoration: const InputDecoration(
                              labelText: 'Date of Birth',
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: _familySizes.contains(_selectedFamilySize)
                          ? _selectedFamilySize
                          : _familySizes.first,
                      decoration: const InputDecoration(
                        labelText: 'Family Size / Household',
                      ),
                      dropdownColor: Theme.of(context).cardTheme.color,
                      items: _familySizes.map((f) {
                        return DropdownMenuItem(
                          value: f,
                          child: Text(f, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedFamilySize = val);
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address (Confidential)',
                        prefixIcon: Icon(
                          Icons.email,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('UPDATE PROFILE'),
                        onPressed: _saveProfile,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
