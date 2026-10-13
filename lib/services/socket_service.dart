import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

final socketServiceProvider = Provider<SocketService>((ref) => SocketService());

class SocketService {
  late IO.Socket socket;

  Function(String)? onPseudo;
  Function(Map)? onMatched;
  Function()? onWaiting;
  Function()? onPartnerLeft;

  void connect() {
    // Remplace par l'URL de ton serveur (Railway, Render, etc.)
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) => print('Connecté au serveur'));

    socket.on('pseudo', (data) => onPseudo?.call(data));
    socket.on('matched', (data) => onMatched?.call(Map<String, dynamic>.from(data)));
    socket.on('waiting', (_) => onWaiting?.call());
    socket.on('partner_left', (_) => onPartnerLeft?.call());
  }

  void findMatch() => socket.emit('find');
  void next() => socket.emit('next');
}
