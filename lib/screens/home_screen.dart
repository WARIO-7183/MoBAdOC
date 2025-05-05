import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  final String phoneNumber;

  const HomeScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabase = Supabase.instance.client;
  late final SupabaseService _supabaseService;
  String _userName = 'User';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(_supabase);
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userProfile = await _supabaseService.getUserProfile(widget.phoneNumber);
      if (userProfile != null && mounted) {
        setState(() {
          _userName = userProfile['name'] ?? 'User';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0C6FF), // Light purple
              Color(0xFFB5D5FF), // Light blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar with user info
              Container(
                padding: const EdgeInsets.all(16.0),
                color: const Color(0xFF1A4A3C),
                child: Row(
                  children: [
                    const Text(
                      'Welcome, ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _isLoading ? 'Loading...' : _userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      // Grid of main options
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: [
                            _buildOptionCard(
                              context,
                              'Chat with AI',
                              Icons.smart_toy,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      phoneNumber: widget.phoneNumber,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildOptionCard(
                              context,
                              'Chat with Doctor',
                              Icons.medical_services,
                              () {
                                // TODO: Implement doctor chat
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: const Color(0xFF4A6FFF),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A4A3C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFF1A4A3C),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1A4A3C),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
} 