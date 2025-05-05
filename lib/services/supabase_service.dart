import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = SupabaseClient(
    dotenv.env['SUPABASE_URL'] ?? '',
    dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  final SupabaseClient _supabaseClient;

  SupabaseService(this._supabaseClient);

  // Create a new user profile
  Future<void> createUserProfile({
    required String phoneNumber,
    required String name,
    required int age,
    required String gender,
    List<String>? healthIssues,
    String? additionalHealthInfo,
  }) async {
    try {
      // Combine health issues and additional info into a single medical history string
      String medicalHistory = '';
      if (healthIssues != null && healthIssues.isNotEmpty) {
        medicalHistory += 'Health Issues: ${healthIssues.join(', ')}';
      }
      if (additionalHealthInfo != null && additionalHealthInfo.isNotEmpty) {
        if (medicalHistory.isNotEmpty) {
          medicalHistory += '\n\n';
        }
        medicalHistory += 'Additional Information: $additionalHealthInfo';
      }

      await _supabaseClient
          .from('user_profiles')
          .upsert({
            'phone_number': phoneNumber,
            'name': name,
            'age': age,
            'gender': gender,
            'Medical_history': medicalHistory,
          });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Get user profile by phone number
  Future<Map<String, dynamic>?> getUserProfile(String phoneNumber) async {
    try {
      final response = await _supabaseClient
          .from('user_profiles')
          .select()
          .eq('phone_number', phoneNumber)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String phoneNumber,
    String? name,
    int? age,
    String? gender,
    List<String>? healthIssues,
    String? additionalHealthInfo,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (age != null) updateData['age'] = age;
      if (gender != null) updateData['gender'] = gender;

      // Combine health issues and additional info into a single medical history string
      if (healthIssues != null || additionalHealthInfo != null) {
        String medicalHistory = '';
        if (healthIssues != null && healthIssues.isNotEmpty) {
          medicalHistory += 'Health Issues: ${healthIssues.join(', ')}';
        }
        if (additionalHealthInfo != null && additionalHealthInfo.isNotEmpty) {
          if (medicalHistory.isNotEmpty) {
            medicalHistory += '\n\n';
          }
          medicalHistory += 'Additional Information: $additionalHealthInfo';
        }
        updateData['Medical_history'] = medicalHistory;
      }

      await _supabaseClient
          .from('user_profiles')
          .update(updateData)
          .eq('phone_number', phoneNumber);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Update chat record for a user
  Future<void> updateChatRecord({
    required String phoneNumber,
    required String chatRecord,
  }) async {
    try {
      await _supabaseClient
          .from('user_profiles')
          .update({'Chat_record': chatRecord})
          .eq('phone_number', phoneNumber);
    } catch (e) {
      throw Exception('Failed to update chat record: $e');
    }
  }

  // Fetch all columns for a user
  Future<Map<String, dynamic>?> getFullUserRecord(String phoneNumber) async {
    try {
      final response = await _supabaseClient
          .from('user_profiles')
          .select()
          .eq('phone_number', phoneNumber)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }
} 