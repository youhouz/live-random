import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/socket_service.dart';
import '../widgets/glass_button.dart';
import 'call_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool isSearching = false;
  String? myPseudo;

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    final socket = ref.read(socketServiceProvider);
    socket.connect();

    socket.onPseudo = (pseudo) {
      setState(() => myPseudo = pseudo);
    };

    socket.onMatched = (data) {
      setState(() => isSearching = false);
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => CallScreen(
            roomId: data['roomId'],
            partnerPseudo: data['partnerPseudo'],
          ),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
        ),
      );
    };

    socket.onWaiting = () {
      setState(() => isSearching = true);
    };
  }

  void _startSearch() {
    ref.read(socketServiceProvider).findMatch();
    setState(() => isSearching = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0B), Color(0xFF131316)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                'LIVE RANDOM',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
              const SizedBox(height: 8),
              Text(
                'Rencontres instantanées • 100% anonyme',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white54,
                ),
              ),
              const Spacer(),
              if (myPseudo != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    'Toi : $myPseudo',
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ).animate().fadeIn(),
              const Spacer(),
              if (isSearching) ...[
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    color: Color(0xFF8B5CF6),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Recherche en cours...',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
                ),
              ] else
                GlassButton(
                  text: 'DÉMARRER',
                  onTap: _startSearch,
                  width: 220,
                  height: 60,
                ).animate().scale(duration: 400.ms),
              const SizedBox(height: 60),
              Text(
                'Swipe si tu n’aimes pas • Aucune donnée stockée',
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
