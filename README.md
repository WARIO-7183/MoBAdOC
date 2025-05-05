# 🩺 Medical Assistant Chatbot

A modern, AI-powered Flutter chat app for medical guidance, multilingual support, and health record management.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

---

## ✨ Features

- **Conversational AI Medical Assistant** (powered by OpenAI GPT-4)
- 🌐 **Multilingual Chat**: Interact in English, Hindi, Kannada, Telugu, Tamil, or Malayalam
- 🧑‍⚕️ **Personalized Profile**: Name, age, gender, and detailed medical history
- 🗂️ **Profile Viewer**: View your profile details anytime from the chat screen
- 💬 **Selectable Options**: Tap on suggested options instead of typing
- 🗣️ **Voice Input**: Speak your questions or responses
- 🖼️ **Upload & Analyze Medical Images/Reports**
- 👍👎 **Like/Dislike Feedback** for responses
- 📋 **Copy Message** functionality
- ➕ **Start New Consultations** easily
- 💾 **Save Chat Record**: Store your entire conversation in the database
- 📝 **Generate PDF Report**: Create a consolidated medical report (profile + chat) as a PDF using OpenAI

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

1. **Onboarding:**
   - Set up your profile (name, age, gender, medical history)
   - Existing users skip profile setup and go straight to the home screen

2. **Chatting:**
   - Select your preferred language (English, Hindi, Kannada, Telugu, Tamil, Malayalam)
   - Ask health questions, describe symptoms, or upload medical images
   - Receive clear, empathetic, and professional responses
   - Tap on suggested options for quick replies

3. **Features:**
   - View your profile anytime from the chat screen
   - Save your chat record to the database with one tap
   - Generate a consolidated PDF report (profile + chat) for sharing or personal records
   - Like/dislike and copy responses
   - Voice input for hands-free chatting
   - Start new consultations anytime

---

## 🖼️ Screenshots

> _Add your app screenshots here for a more beautiful README!_

---

## 🔒 Security & Privacy
- All medical data is processed securely
- Images are converted to base64 for secure transmission
- Chat records and reports are stored securely in Supabase
- **Not a replacement for professional medical care**

---

## 🛠️ Technical Details

**Key Dependencies:**
- `provider` – State management
- `supabase_flutter` – User profile & backend
- `http` – API communication
- `flutter_dotenv` – Environment configuration
- `image_picker`, `file_picker` – Image/file handling
- `pdf`, `path_provider` – PDF report generation and storage
- `flutter_tts` – Text-to-speech
- `permission_handler` – Permissions

**Architecture:**
- Provider pattern for state management
- Clean separation of UI and business logic
- Modular, maintainable codebase

---

## ⚠️ Disclaimer

> This app provides basic medical information and guidance. It is **not** a substitute for professional medical advice, diagnosis, or treatment. Always consult a qualified healthcare provider for medical concerns.

---

## 🤝 Contributing

Contributions are welcome! Please open issues or submit pull requests.

---

## 📄 License

MIT License – see the [LICENSE](LICENSE) file for details.


