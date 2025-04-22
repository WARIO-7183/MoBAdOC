class ApiConfig {
  static String? _apiKey;

  static void setApiKey(String key) {
    _apiKey = key;
  }

  static String? get apiKey => _apiKey;
} 