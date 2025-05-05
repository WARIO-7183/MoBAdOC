import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isExistingUser;
  final Map<String, dynamic>? existingProfile;

  const ProfileSetupScreen({
    super.key,
    required this.phoneNumber,
    this.isExistingUser = false,
    this.existingProfile,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _additionalHealthInfoController = TextEditingController();
  String _selectedGender = 'Male';
  final _supabase = Supabase.instance.client;
  late final SupabaseService _supabaseService;
  
  // List of common health issues
  final List<String> _healthIssues = [
    'Diabetes',
    'High Blood Pressure',
    'Heart Disease',
    'Kidney Problems',
    'Liver Disease',
    'Lung Disease',
    'Cancer',
    'Transplants',
    'Major Surgeries',
    'Chronic Pain',
    'Mental Health Conditions',
    'Autoimmune Disorders',
  ];
  
  // Selected health issues
  List<String> _selectedHealthIssues = [];

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(_supabase);
    
    if (widget.isExistingUser && widget.existingProfile != null) {
      _nameController.text = widget.existingProfile!['name'] ?? '';
      _ageController.text = widget.existingProfile!['age']?.toString() ?? '';
      _selectedGender = widget.existingProfile!['gender'] ?? 'Male';
      
      // Parse Medical_history field
      final medicalHistory = widget.existingProfile!['Medical_history'] as String?;
      if (medicalHistory != null && medicalHistory.isNotEmpty) {
        // Split the medical history into health issues and additional info
        final parts = medicalHistory.split('\n\n');
        if (parts.isNotEmpty) {
          // Parse health issues
          if (parts[0].startsWith('Health Issues: ')) {
            final issues = parts[0].substring('Health Issues: '.length).split(', ');
            _selectedHealthIssues = issues;
          }
          
          // Parse additional info
          if (parts.length > 1 && parts[1].startsWith('Additional Information: ')) {
            _additionalHealthInfoController.text = parts[1].substring('Additional Information: '.length);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _additionalHealthInfoController.dispose();
    super.dispose();
  }

  Future<void> _handleProfileSetup() async {
    if (_formKey.currentState!.validate()) {
      try {
        final name = _nameController.text;
        final age = int.parse(_ageController.text);
        final gender = _selectedGender;
        final additionalHealthInfo = _additionalHealthInfoController.text;

        if (widget.isExistingUser) {
          // Update existing profile
          await _supabaseService.updateUserProfile(
            phoneNumber: widget.phoneNumber,
            name: name,
            age: age,
            gender: gender,
            healthIssues: _selectedHealthIssues,
            additionalHealthInfo: additionalHealthInfo,
          );
        } else {
          // Create new profile
          await _supabaseService.createUserProfile(
            phoneNumber: widget.phoneNumber,
            name: name,
            age: age,
            gender: gender,
            healthIssues: _selectedHealthIssues,
            additionalHealthInfo: additionalHealthInfo,
          );
        }

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              phoneNumber: widget.phoneNumber,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
        backgroundColor: const Color(0xFF4A6FFF),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0C6FF),
              Color(0xFFB5D5FF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Complete Your Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _ageController,
                    label: 'Age',
                    icon: Icons.calendar_today,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age <= 0 || age > 120) {
                        return 'Please enter a valid age';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildGenderDropdown(),
                  const SizedBox(height: 16),
                  _buildHealthHistorySection(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _handleProfileSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6FFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      widget.isExistingUser ? 'Update Profile' : 'Create Profile',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        items: ['Male', 'Female', 'Other']
            .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedGender = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildHealthHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _healthIssues.map((issue) {
                  return FilterChip(
                    label: Text(issue),
                    selected: _selectedHealthIssues.contains(issue),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedHealthIssues.add(issue);
                        } else {
                          _selectedHealthIssues.remove(issue);
                        }
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF4A6FFF).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF4A6FFF),
                    labelStyle: TextStyle(
                      color: _selectedHealthIssues.contains(issue)
                          ? const Color(0xFF4A6FFF)
                          : Colors.black87,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  controller: _additionalHealthInfoController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Additional Health Information',
                    hintText: 'Please provide any other relevant health information',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
} 