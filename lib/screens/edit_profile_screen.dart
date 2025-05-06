import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String phoneNumber;
  final Map<String, dynamic> userProfile;

  const EditProfileScreen({
    super.key,
    required this.phoneNumber,
    required this.userProfile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _otherMedicalHistoryController;
  String _selectedGender = '';
  bool _isLoading = false;
  late final SupabaseService _supabaseService;
  
  // Medical history options
  final Map<String, bool> _medicalConditions = {
    'Chronic Disease': false,
    'Kidney Disease': false,
    'Diabetes': false,
    'Liver Related Problems': false,
    'Surgeries': false,
  };

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(Supabase.instance.client);
    _nameController = TextEditingController(text: widget.userProfile['name'] ?? '');
    _ageController = TextEditingController(text: widget.userProfile['age']?.toString() ?? '');
    _otherMedicalHistoryController = TextEditingController();
    _selectedGender = widget.userProfile['gender'] ?? '';
    
    // Parse existing medical history
    _parseExistingMedicalHistory();
  }

  void _parseExistingMedicalHistory() {
    final existingHistory = widget.userProfile['Medical_history'] ?? '';
    if (existingHistory.isNotEmpty) {
      // Check for each condition in the existing history
      for (var condition in _medicalConditions.keys) {
        if (existingHistory.toLowerCase().contains(condition.toLowerCase())) {
          _medicalConditions[condition] = true;
        }
      }
      
      // Extract "Other" conditions if present
      if (existingHistory.contains('Other:')) {
        final otherPart = existingHistory.split('Other:').last.trim();
        _otherMedicalHistoryController.text = otherPart;
      }
    }
  }

  String _getFormattedMedicalHistory() {
    final selectedConditions = _medicalConditions.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    
    String history = selectedConditions.join(', ');
    
    if (_otherMedicalHistoryController.text.isNotEmpty) {
      if (history.isNotEmpty) {
        history += '\nOther: ';
      } else {
        history = 'Other: ';
      }
      history += _otherMedicalHistoryController.text;
    }
    
    return history;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _otherMedicalHistoryController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Log the data being sent to update
      debugPrint('Updating profile for phone: ${widget.phoneNumber}');
      debugPrint('Name: ${_nameController.text}');
      debugPrint('Age: ${_ageController.text}');
      debugPrint('Gender: $_selectedGender');
      debugPrint('Medical History: ${_getFormattedMedicalHistory()}');

      await _supabaseService.updateUserProfile(
        phoneNumber: widget.phoneNumber,
        name: _nameController.text,
        age: int.tryParse(_ageController.text) ?? 0,
        gender: _selectedGender,
        additionalHealthInfo: _getFormattedMedicalHistory(),
      );

      debugPrint('Profile update successful');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF00A884),
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Age Field
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.cake),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your age';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid age';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Gender Field
                    const Text(
                      'Gender',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Male',
                          groupValue: _selectedGender,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value!;
                            });
                          },
                        ),
                        const Text('Male'),
                        const SizedBox(width: 16),
                        Radio<String>(
                          value: 'Female',
                          groupValue: _selectedGender,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value!;
                            });
                          },
                        ),
                        const Text('Female'),
                        const SizedBox(width: 16),
                        Radio<String>(
                          value: 'Other',
                          groupValue: _selectedGender,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value!;
                            });
                          },
                        ),
                        const Text('Other'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Medical History Section
                    const Text(
                      'Medical History',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select all that apply:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._medicalConditions.entries.map((entry) {
                      return CheckboxListTile(
                        title: Text(entry.key),
                        value: entry.value,
                        onChanged: (bool? value) {
                          setState(() {
                            _medicalConditions[entry.key] = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF00A884),
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                    
                    // Other Medical History Field
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _otherMedicalHistoryController,
                      decoration: const InputDecoration(
                        labelText: 'Other Medical Conditions',
                        prefixIcon: Icon(Icons.medical_services),
                        alignLabelWithHint: true,
                        hintText: 'Enter any other medical conditions...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A884),
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 