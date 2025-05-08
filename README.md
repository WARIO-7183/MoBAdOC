# 🩺 Medical Assistant Chatbot

A modern, AI-powered Flutter chat app for medical guidance, multilingual support, and health record management.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

---

## ✨ Features

- **AI-Powered Medical Assistant** (powered by OpenAI GPT-4)
- 🌐 **Multilingual Support**: Native support for English, Hindi, Kannada, Telugu, Tamil, and Malayalam
- 👤 **User Authentication**: Secure login and profile management
- 🧑‍⚕️ **Comprehensive Profile Management**:
  - Create and edit detailed medical profiles
  - Store medical history and personal information
  - View and update profile information anytime
- 💬 **Intelligent Chat Interface**:
  - Natural language medical consultations
  - Voice input support
  - Suggested response options
  - Message feedback system (like/dislike)
  - Copy message functionality
- 📱 **Modern UI/UX**:
  - Clean, intuitive interface
  - Responsive design
  - Native font support for all supported languages
  - Dark/light theme support
- 🔒 **Secure Data Management**:
  - Supabase backend integration
  - Secure user authentication
  - Encrypted data storage
  - Environment variable configuration

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest)
- Dart SDK (latest)
- Android Studio / VS Code with Flutter extensions

### Installation

```bash
git clone [repository-url]
cd medical-assistant-chatbot
flutter pub get
```

1. **Set up your environment variables:**
   - Create a `.env` file in the root directory:
     ```
     OPENAI_API_KEY=your_openai_api_key_here
     SUPABASE_URL=your_supabase_url
     SUPABASE_ANON_KEY=your_supabase_anon_key
     ```
2. **Run the app:**
   ```bash
   flutter run
   ```

---

## 🏥 How It Works

1. **Authentication:**
   - Secure login system
   - New user registration
   - Profile setup for first-time users

2. **Profile Management:**
   - Create detailed medical profile
   - Update personal and medical information
   - View profile details anytime

3. **Chat Interface:**
   - Select preferred language
   - Natural conversation with AI assistant
   - Voice input support
   - Quick response options
   - Message feedback system

---

## 🔒 Security & Privacy
- Secure user authentication through Supabase
- Encrypted data transmission
- Secure storage of medical information
- Environment variable protection
- **Not a replacement for professional medical care**

---

## 🛠️ Technical Details

**Key Dependencies:**
- `provider` – State management
- `supabase_flutter` – Authentication and backend
- `flutter_dotenv` – Environment configuration
- `google_fonts` – Multilingual font support
- `flutter_tts` – Text-to-speech
- `permission_handler` – Permissions

**Architecture:**
- Provider pattern for state management
- Clean architecture with separation of concerns
- Modular and maintainable codebase
- Multilingual support with native fonts

---

## ⚠️ Disclaimer

> This app provides basic medical information and guidance. It is **not** a substitute for professional medical advice, diagnosis, or treatment. Always consult a qualified healthcare provider for medical concerns.

---

## 🤝 Contributing

Contributions are welcome! Please open issues or submit pull requests.

---

## 📄 License

MIT License – see the [LICENSE](LICENSE) file for details.


