import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AICallScreen extends StatefulWidget {
  final String phoneNumber;
  const AICallScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<AICallScreen> createState() => _AICallScreenState();
}

class _AICallScreenState extends State<AICallScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _recordedFilePath;
  bool _isProcessing = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/aidoc_call.wav';
    await _recorder.startRecorder(
      toFile: filePath,
      codec: Codec.pcm16WAV,
    );
    setState(() {
      _isRecording = true;
      _recordedFilePath = filePath;
    });
  }

  Future<void> _stopRecordingAndSend() async {
    setState(() { _isProcessing = true; });
    await _recorder.stopRecorder();
    setState(() { _isRecording = false; });
    if (_recordedFilePath == null) return;
    try {
      final backendUrl = dotenv.env['BACKEND_URL'] ?? 'http://127.0.0.1:5000';
      final uri = Uri.parse('$backendUrl/talk');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('audio', _recordedFilePath!));
      final response = await request.send();
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        final dir = await getTemporaryDirectory();
        final audioPath = '${dir.path}/aidoc_response.mp3';
        final audioFile = File(audioPath);
        await audioFile.writeAsBytes(bytes);
        await _audioPlayer.play(DeviceFileSource(audioPath));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() { _isProcessing = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25D366),
      body: Center(
        child: Container(
          width: 340,
          height: 600,
          decoration: BoxDecoration(
            color: const Color(0xFF222E35),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 16)],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF374045),
                    child: Icon(Icons.person, size: 80, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text('AIDOC', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (_isProcessing)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CallButton(icon: Icons.volume_up),
                      _CallButton(icon: Icons.videocam),
                      _CallButton(icon: Icons.call_end, color: Colors.red),
                    ],
                  ),
                  const SizedBox(height: 100), // Space for the mic button
                ],
              ),
              // Large mic button at the bottom center
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _isRecording ? _stopRecordingAndSend : _startRecording,
                      child: CircleAvatar(
                        radius: 38,
                        backgroundColor: _isRecording ? Colors.red : Colors.white,
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          color: _isRecording ? Colors.white : Colors.black,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isRecording ? 'Tap to stop & send' : 'Tap to record',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _CallButton({required this.icon, this.color = Colors.white});
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white24,
      radius: 28,
      child: Icon(icon, color: color, size: 28),
    );
  }
} 