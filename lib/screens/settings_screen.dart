import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../database/database_helper.dart';
import '../database/web_database_helper.dart';
import '../providers/theme_provider.dart';
import 'profile_setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = kIsWeb
          ? await WebDatabaseHelper.instance.readProfile()
          : await DatabaseHelper.instance.readProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E1E1E),
                    const Color(0xFF2D2D2D),
                  ]
                : [
                    const Color(0xFF00CDB4),
                    const Color(0xFF00A594),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF121212) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_profile != null) _buildProfileCard(),
          if (_profile == null) _buildCreateProfileCard(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Health Information'),
          const SizedBox(height: 12),
          if (_profile != null) _buildHealthInfoCard(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Goals'),
          const SizedBox(height: 12),
          if (_profile != null) _buildGoalsCard(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('App Settings'),
          const SizedBox(height: 12),
          _buildAppSettingsCard(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('About'),
          const SizedBox(height: 12),
          _buildAboutCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3142),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: const Color(0xFF00CDB4).withAlpha(25),
                  child: Text(
                    _profile!.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00CDB4),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profile!.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_profile!.age} years • ${_profile!.gender[0].toUpperCase()}${_profile!.gender.substring(1)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF00CDB4)),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileSetupScreen(
                          existingProfile: _profile,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadProfile();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateProfileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileSetupScreen(),
            ),
          );
          if (result == true) {
            _loadProfile();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00CDB4).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_add,
                  color: Color(0xFF00CDB4),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Your Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Set up your profile to get personalized insights',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthInfoCard() {
    final bmi = _profile!.bmi;
    final bmiCategory = _profile!.bmiCategory;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem('Height', '${_profile!.height.toStringAsFixed(0)} cm', Icons.height),
                _buildInfoItem('Weight', '${_profile!.weight.toStringAsFixed(1)} kg', Icons.monitor_weight),
                _buildInfoItem('BMI', bmi.toStringAsFixed(1), Icons.analytics),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getBmiColor(bmiCategory).withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'BMI Category: $bmiCategory',
                style: TextStyle(
                  color: _getBmiColor(bmiCategory),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF6C63FF), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getBmiColor(String category) {
    switch (category) {
      case 'Underweight':
        return const Color(0xFF4DD0E1);
      case 'Normal':
        return const Color(0xFF66BB6A);
      case 'Overweight':
        return const Color(0xFFFFA726);
      case 'Obese':
        return const Color(0xFFEF5350);
      default:
        return Colors.grey;
    }
  }

  Widget _buildGoalsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildGoalItem(
              'Steps',
              _profile!.dailyStepsGoal.toString(),
              Icons.directions_walk,
              const Color(0xFF66BB6A),
            ),
            const Divider(height: 24),
            _buildGoalItem(
              'Water',
              '${_profile!.dailyWaterGoal.toStringAsFixed(1)} L',
              Icons.water_drop,
              const Color(0xFF4DD0E1),
            ),
            const Divider(height: 24),
            _buildGoalItem(
              'Calories',
              '${_profile!.dailyCaloriesGoal.toStringAsFixed(0)} kcal',
              Icons.local_fire_department,
              const Color(0xFFFFA726),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C63FF),
          ),
        ),
      ],
    );
  }

  Widget _buildAppSettingsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildSettingsTile(
            'Notifications',
            Icons.notifications_outlined,
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Notification Settings'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Stay motivated with daily reminders!',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      _buildNotificationOption('Daily Step Reminder', true),
                      _buildNotificationOption('Water Intake Reminder', true),
                      _buildNotificationOption('Achievement Unlocked', true),
                      _buildNotificationOption('Weekly Summary', false),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification preferences saved!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00CDB4),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            'Theme',
            Icons.palette_outlined,
            () {
              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Theme Settings'),
                  content: StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildThemeOptionInteractive(
                            'Light Theme',
                            Icons.light_mode,
                            themeProvider.themeMode == ThemeMode.light,
                            () {
                              themeProvider.setThemeMode(ThemeMode.light);
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildThemeOptionInteractive(
                            'Dark Theme',
                            Icons.dark_mode,
                            themeProvider.themeMode == ThemeMode.dark,
                            () {
                              themeProvider.setThemeMode(ThemeMode.dark);
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildThemeOptionInteractive(
                            'System Default',
                            Icons.settings_suggest,
                            themeProvider.themeMode == ThemeMode.system,
                            () {
                              themeProvider.setThemeMode(ThemeMode.system);
                              setState(() {});
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            'Units',
            Icons.straighten_outlined,
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Unit Settings'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Distance & Height',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildUnitOption('Metric (cm, km)', true),
                      _buildUnitOption('Imperial (ft, mi)', false),
                      const SizedBox(height: 16),
                      const Text(
                        'Weight',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildUnitOption('Kilograms (kg)', true),
                      _buildUnitOption('Pounds (lbs)', false),
                      const SizedBox(height: 16),
                      const Text(
                        'Liquid',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildUnitOption('Liters (L)', true),
                      _buildUnitOption('Fluid Ounces (fl oz)', false),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Unit preferences saved!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00CDB4),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildSettingsTile(
            'Privacy Policy',
            Icons.privacy_tip_outlined,
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Privacy Policy'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'HealthMate Privacy Policy\n\n'
                      'We take your privacy seriously. Your health data is stored '
                      'locally on your device and is never shared with third parties.\n\n'
                      'Data Collection:\n'
                      '• Health metrics (steps, calories, water intake)\n'
                      '• User profile information\n'
                      '• App usage statistics\n\n'
                      'Data Storage:\n'
                      'All data is stored securely on your device using SQLite database '
                      '(mobile) or browser localStorage (web).\n\n'
                      'Data Security:\n'
                      'Your data is protected and only accessible through this app on your device.',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            'Terms of Service',
            Icons.description_outlined,
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Terms of Service'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'HealthMate Terms of Service\n\n'
                      'By using HealthMate, you agree to the following terms:\n\n'
                      '1. Use of Service\n'
                      'HealthMate is a personal health tracking application designed to '
                      'help you monitor your daily health activities.\n\n'
                      '2. User Responsibilities\n'
                      '• Provide accurate health information\n'
                      '• Use the app for personal health tracking only\n'
                      '• Keep your device secure\n\n'
                      '3. Disclaimer\n'
                      'HealthMate is not a medical device and should not be used as a '
                      'substitute for professional medical advice. Always consult with '
                      'healthcare professionals for medical concerns.\n\n'
                      '4. Data Accuracy\n'
                      'While we strive for accuracy, we do not guarantee the accuracy of '
                      'health calculations and recommendations.\n\n'
                      '5. Changes to Terms\n'
                      'We reserve the right to modify these terms at any time.',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            'App Version',
            Icons.info_outline,
            null,
            trailing: const Text(
              'v1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    IconData icon,
    VoidCallback? onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00CDB4)),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildNotificationOption(String title, bool enabled) {
    return Row(
      children: [
        Expanded(
          child: Text(title),
        ),
        Switch(
          value: enabled,
          onChanged: (value) {},
          activeThumbColor: const Color(0xFF00CDB4),
        ),
      ],
    );
  }

  Widget _buildThemeOptionInteractive(String title, IconData icon, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? const Color(0xFF00CDB4) : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected ? const Color(0xFF00CDB4).withAlpha(25) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xFF00CDB4) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? const Color(0xFF00CDB4) : Colors.black87,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF00CDB4),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitOption(String title, bool selected) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? const Color(0xFF00CDB4) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
