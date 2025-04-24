# ChatBot Application

A modern Flutter-based chat application with real-time messaging capabilities.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## Features

- Real-time chat functionality
- Clean and modern user interface
- State management using providers
- Environment configuration support
- Cross-platform support (Android, iOS, Web)

## Project Structure

```
lib/
├── config/         # Configuration files
├── models/         # Data models
├── providers/      # State management
├── screens/        # UI screens
└── services/       # Business logic
```

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK (latest version)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone [your-repository-url]
cd chatbot_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up environment variables:
   - Copy `.env.example` to `.env`
   - Update the environment variables as needed

4. Run the application:
```bash
flutter run
```

## Configuration

The application uses environment variables for configuration. Create a `.env` file in the root directory with the following variables:

```
API_BASE_URL=your_api_url
API_KEY=your_api_key
```

## Development

### Architecture

The application follows a clean architecture pattern with:
- Models: Data structures and business objects
- Services: Business logic and API interactions
- Providers: State management
- Screens: UI components

### State Management

The application uses the Provider package for state management, making it easy to handle application state and data flow.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email [your-email] or open an issue in the repository.
