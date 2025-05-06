import 'package:flutter/material.dart';

class TranslationService {
  static const Map<String, String> _languageCodes = {
    'English': 'en',
    'Hindi': 'hi',
    'Kannada': 'kn',
    'Tamil': 'ta',
    'Telugu': 'te',
    'Malayalam': 'ml',
  };

  // Native language names with proper Unicode encoding
  static const Map<String, String> _languageNames = {
    'en': 'English',
    'hi': 'हिन्दी',  // Properly encoded Hindi
    'kn': 'ಕನ್ನಡ',   // Properly encoded Kannada
    'ta': 'தமிழ்',   // Properly encoded Tamil
    'te': 'తెలుగు',  // Properly encoded Telugu
    'ml': 'മലയാളം',  // Properly encoded Malayalam
  };
  
  static Map<String, String> get languageCodes => _languageCodes;
  static Map<String, String> get languageNames => _languageNames;

  static String getLanguageCode(String languageName) {
    return _languageCodes[languageName] ?? 'en';
  }

  static String getLanguageName(String languageCode) {
    return _languageNames[languageCode] ?? 'English';
  }

  static String getNativeLanguageName(String languageCode) {
    switch (languageCode) {
      case 'hi': return 'हिन्दी';
      case 'kn': return 'ಕನ್ನಡ';
      case 'ta': return 'தமிழ்';
      case 'te': return 'తెలుగు';
      case 'ml': return 'മലയാളം';
      default: return 'English';
    }
  }

  static List<String> getAvailableLanguages() {
    return _languageCodes.keys.toList();
  }

  static String getNativeName(String languageCode) {
    return _languageNames[languageCode] ?? 'English';
  }

  // This method is a placeholder - no actual translation happens here
  // Since we're using the LLM directly for translation in the chat service
  static Future<String> translateText(String text, String targetLanguage) async {
    // Simply return the original text as we'll be using the OpenAI LLM for translation
    // The actual translation happens in the ChatService when sending messages to the LLM
    return text;
  }
} 