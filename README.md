# 🩺 Medical Assistant Chatbot

A modern, AI-powered Flutter chat app for medical guidance and report analysis.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

---

## ✨ Features

- **Conversational AI Medical Assistant** (powered by OpenAI GPT-4)
- 📋 Asks about your chronic conditions (diabetes, hypertension, etc.) at the start
- 🧑‍⚕️ Personalized advice based on your profile (name, age, gender, medical history)
- 💬 Clean, modern chat interface
- 🖼️ Upload and analyze medical images/reports
- 🗣️ Voice input support
- 👍👎 Like/Dislike feedback for responses
- 📋 Copy message functionality
- ➕ Start new consultations easily

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
     ```
2. **Run the app:**
   ```bash
   flutter run
   ```

---

## 🏥 How It Works

1. **Onboarding:**
   - Set up your profile (name, age, gender)
   - On first chat, the AI asks about your chronic conditions (e.g., diabetes, high blood pressure, heart/kidney/liver problems)
   - No more repetitive prompts for name/age/gender!

2. **Chatting:**
   - Ask health questions or describe symptoms
   - Upload medical images or reports for instant AI analysis
   - Receive clear, empathetic, and professional responses

3. **Features:**
   - Start new consultations anytime
   - Like/dislike and copy responses
   - Voice input for hands-free chatting

---

## 🖼️ Screenshots

> _Add your app screenshots here for a more beautiful README!_

---

## 🔒 Security & Privacy
- All medical data is processed securely
- Images are converted to base64 for secure transmission
- No medical data is stored permanently
- **Not a replacement for professional medical care**

---

## 🛠️ Technical Details

**Key Dependencies:**
- `provider` – State management
- `supabase_flutter` – User profile & backend
- `http` – API communication
- `flutter_dotenv` – Environment configuration
- `image_picker`, `file_picker` – Image/file handling
- `speech_to_text` – Voice input

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


