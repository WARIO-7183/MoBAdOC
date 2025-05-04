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
  }) async {
    try {
      await _supabaseClient
          .from('user_profiles')
          .upsert({
            'phone_number': phoneNumber,
            'name': name,
            'age': age,
            'gender': gender,
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
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (age != null) updateData['age'] = age;
      if (gender != null) updateData['gender'] = gender;

      await _supabaseClient
          .from('user_profiles')
          .update(updateData)
          .eq('phone_number', phoneNumber);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
} 