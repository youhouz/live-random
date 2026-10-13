import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../services/socket_service.dart';
import '../services/agora_service.dart';
import '../widgets/glass_button.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String partnerPseudo;

  const CallScreen({
    super.key,
    required this.roomId,
    required this.partnerPseudo,
  });

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  final AgoraService _agora = AgoraService();
  bool _joined = false;

  @override
  void initState() {
    super.initState();
    _initAgora();
    _listenSocket();
  }

  Future<void> _initAgora() async {
    await _agora.init();
    await _agora.joinChannel(widget.roomId);
    setState(() => _joined = true);
  }

  void _listenSocket() {
    final socket = ref.read(socketServiceProvider);
    socket.onPartnerLeft = () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La personne est partie')),
        );
      }
    };
  }

  void _next() {
    ref.read(socketServiceProvider).next();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _agora.leave();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_joined)
            AgoraVideoView(controller: _agora.remoteController)
          else
            const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6))),

          Positioned(
            top: 60,
            right: 20,
            child: Container(
              width: 110,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: AgoraVideoView(controller: _agora.localController),
              ),
            ),
          ),

          Positioned(
            top: 60,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.partnerPseudo,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GlassButton(
                  text: 'NEXT',
                  icon: Icons.skip_next_rounded,
                  onTap: _next,
                  color: Colors.white12,
                  width: 140,
                ),
                GlassButton(
                  text: 'LIKE',
                  icon: Icons.favorite_rounded,
                  onTap: () {},
                  color: const Color(0xFF8B5CF6),
                  width: 140,
                ),
              ],
            ).animate().slideY(begin: 0.3, duration: 400.ms),
          ),
        ],
      ),
    );
  }
}
