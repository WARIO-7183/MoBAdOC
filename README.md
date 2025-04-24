# Medical Assistant Chatbot

A modern Flutter-based chat application with real-time messaging capabilities.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## Features

### Chat Interface
- Clean, modern WhatsApp-style chat interface
- Real-time message updates
- Support for text messages and medical images
- Voice input support for easy communication
- Like/Dislike feedback system for responses
- Copy message functionality
- New chat session creation

### Image Analysis
- Upload medical reports and images through:
  - Gallery selection
  - Camera capture
  - File attachment (supports PDF, JPG, JPEG, PNG)
- Image preview in chat
- Full-screen image viewer with zoom capabilities
- AI-powered medical report analysis

### AI Assistant Capabilities
- Natural, conversational interactions
- Structured medical consultations
- Symptom analysis and basic diagnosis suggestions
- Medicine recommendations (with both brand and generic names)
- Clear disclaimers about AI limitations
- Professional and empathetic communication

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK (latest version)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone [repository-url]
```

2. Navigate to the project directory:
```bash
cd medical-assistant-chatbot
```

3. Install dependencies:
```bash
flutter pub get
```

4. Create a `.env` file in the root directory and add your Groq API key:
```
GROQ_API_KEY=your_api_key_here
```

5. Run the application:
```bash
flutter run
```

## Usage

1. **Starting a Conversation**
   - Launch the app
   - The AI will ask for your name, age, and gender
   - Describe your medical concerns

2. **Uploading Medical Reports**
   - Click the attachment icon (📎) to upload files
   - Use the camera icon (📷) to take photos
   - Supported formats: PDF, JPG, JPEG, PNG
   - View uploaded images in full screen by tapping them

3. **Voice Input**
   - Press and hold the microphone icon to record
   - Release to send the voice input
   - Your speech will be converted to text

4. **Managing Conversations**
   - Start a new consultation using the '+' button
   - Like or dislike AI responses
   - Copy messages using the copy icon

## Security and Privacy

- All medical data is processed securely
- Images are converted to base64 format for secure transmission
- No medical data is stored permanently
- The app is not a replacement for professional medical care

## Technical Details

### Dependencies
- `provider`: State management
- `speech_to_text`: Voice input processing
- `image_picker`: Image capture and selection
- `file_picker`: File selection and handling
- `http`: API communication
- `flutter_dotenv`: Environment configuration

### Architecture
- Provider pattern for state management
- Clean separation of UI and business logic
- Modular component design
- Efficient image handling and processing

## Disclaimer

This application is designed to provide basic medical information and guidance. It is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of qualified healthcare providers with questions regarding medical conditions.

## Contributing

Contributions are welcome! Please feel free to submit pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


