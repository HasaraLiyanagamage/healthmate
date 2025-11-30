import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_profile.dart';
import '../database/database_helper.dart';
import '../database/web_database_helper.dart';
import 'new_dashboard_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final UserProfile? existingProfile;
  final bool isFirstTime;

  const ProfileSetupScreen({
    super.key,
    this.existingProfile,
    this.isFirstTime = false,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _stepsGoalController;
  late TextEditingController _waterGoalController;
  late TextEditingController _caloriesGoalController;
  String _selectedGender = 'male';
  String _selectedActivityLevel = 'moderate';
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    final profile = widget.existingProfile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _ageController = TextEditingController(text: profile?.age.toString() ?? '');
    _heightController = TextEditingController(text: profile?.height.toString() ?? '');
    _weightController = TextEditingController(text: profile?.weight.toString() ?? '');
    _stepsGoalController = TextEditingController(text: profile?.dailyStepsGoal.toString() ?? '10000');
    _waterGoalController = TextEditingController(text: profile?.dailyWaterGoal.toString() ?? '2.5');
    _caloriesGoalController = TextEditingController(text: profile?.dailyCaloriesGoal.toString() ?? '2000');
    _selectedGender = profile?.gender ?? 'male';
    _selectedActivityLevel = profile?.activityLevel ?? 'moderate';
  }
  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _stepsGoalController.dispose();
    _waterGoalController.dispose();
    _caloriesGoalController.dispose();
    super.dispose();
  }
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final profile = UserProfile(
        id: widget.existingProfile?.id,
        name: _nameController.text,
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        dailyStepsGoal: int.parse(_stepsGoalController.text),
        dailyWaterGoal: double.parse(_waterGoalController.text),
        dailyCaloriesGoal: double.parse(_caloriesGoalController.text),
        activityLevel: _selectedActivityLevel,
        createdAt: widget.existingProfile?.createdAt,
        updatedAt: DateTime.now(),
      );
      if (widget.existingProfile == null) {
        debugPrint('Creating new profile for: ${profile.name}');
        if (kIsWeb) {
          await WebDatabaseHelper.instance.createProfile(profile);
        } else {
          await DatabaseHelper.instance.createProfile(profile);
        }
        debugPrint('Profile created successfully');
      } else {
        debugPrint('Updating profile for: ${profile.name}');
        if (kIsWeb) {
          await WebDatabaseHelper.instance.updateProfile(profile);
        } else {
          await DatabaseHelper.instance.updateProfile(profile);
        }
        debugPrint('Profile updated successfully');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingProfile == null 
              ? 'Profile created successfully!' 
              : 'Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // If it's first time setup, replace the current screen with dashboard
        if (widget.isFirstTime) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const NewDashboardScreen(),
            ),
          );
        } else {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FF),
      appBar: widget.isFirstTime ? null : AppBar(
        title: Text(widget.existingProfile == null ? 'Create Profile' : 'Edit Profile'),
        backgroundColor: const Color(0xFF00CDB4),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.isFirstTime) ...[
                  const Icon(
                    Icons.person_add,
                    size: 80,
                    color: Color(0xFF00CDB4),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome to HealthMate!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let\'s set up your profile to personalize your experience',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                
                _buildSectionTitle('Personal Information'),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _nameController,
                  label: 'Name',
                  icon: Icons.person,
                  validator: (value) => value?.isEmpty ?? true ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _ageController,
                        label: 'Age',
                        icon: Icons.cake,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          final age = int.tryParse(value!);
                          if (age == null || age < 1 || age > 120) return 'Invalid age';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildGenderSelector(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildSectionTitle('Body Measurements'),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _heightController,
                        label: 'Height (cm)',
                        icon: Icons.height,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          final height = double.tryParse(value!);
                          if (height == null || height < 50 || height > 300) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _weightController,
                        label: 'Weight (kg)',
                        icon: Icons.monitor_weight,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          final weight = double.tryParse(value!);
                          if (weight == null || weight < 20 || weight > 500) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildSectionTitle('Activity Level'),
                const SizedBox(height: 16),
                _buildActivityLevelSelector(),
                const SizedBox(height: 24),
                
                _buildSectionTitle('Daily Goals'),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _stepsGoalController,
                  label: 'Steps Goal',
                  icon: Icons.directions_walk,
                  keyboardType: TextInputType.number,
                  suffix: 'steps',
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    final steps = int.tryParse(value!);
                    if (steps == null || steps < 1000) return 'Min 1000 steps';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _waterGoalController,
                  label: 'Water Goal',
                  icon: Icons.water_drop,
                  keyboardType: TextInputType.number,
                  suffix: 'liters',
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    final water = double.tryParse(value!);
                    if (water == null || water < 0.5) return 'Min 0.5 liters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _caloriesGoalController,
                  label: 'Calories Goal',
                  icon: Icons.local_fire_department,
                  keyboardType: TextInputType.number,
                  suffix: 'kcal',
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    final calories = double.tryParse(value!);
                    if (calories == null || calories < 500) return 'Min 500 kcal';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00CDB4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.existingProfile == null ? 'Create Profile' : 'Update Profile',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                
                if (widget.isFirstTime) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const NewDashboardScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF00CDB4),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF00CDB4)),
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Male')),
            DropdownMenuItem(value: 'female', child: Text('Female')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedGender = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildActivityLevelSelector() {
    final levels = [
      {'value': 'sedentary', 'label': 'Sedentary', 'desc': 'Little or no exercise'},
      {'value': 'light', 'label': 'Light', 'desc': '1-3 days/week'},
      {'value': 'moderate', 'label': 'Moderate', 'desc': '3-5 days/week'},
      {'value': 'active', 'label': 'Active', 'desc': '6-7 days/week'},
      {'value': 'very_active', 'label': 'Very Active', 'desc': 'Intense daily exercise'},
    ];

    return Column(
      children: levels.map((level) {
        final isSelected = _selectedActivityLevel == level['value'];
        return GestureDetector(
          onTap: () => setState(() => _selectedActivityLevel = level['value']!),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00CDB4).withAlpha(25) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF00CDB4) : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0xFF00CDB4) : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level['label']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? const Color(0xFF00CDB4) : Colors.black87,
                        ),
                      ),
                      Text(
                        level['desc']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
