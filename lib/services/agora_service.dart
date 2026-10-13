import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  // ← Remplace par ton App ID Agora (gratuit sur agora.io)
  static const String appId = 'TON_AGORA_APP_ID';

  late RtcEngine engine;
  late VideoViewController localController;
  late VideoViewController remoteController;
  int? remoteUid;

  Future<void> init() async {
    await [Permission.microphone, Permission.camera].request();

    engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(appId: appId));

    engine.registerEventHandler(RtcEngineEventHandler(
      onUserJoined: (connection, uid, elapsed) {
        remoteUid = uid;
      },
      onUserOffline: (connection, uid, reason) {
        remoteUid = null;
      },
    ));

    await engine.enableVideo();
    await engine.startPreview();

    localController = VideoViewController(
      rtcEngine: engine,
      canvas: const VideoCanvas(uid: 0),
    );

    remoteController = VideoViewController.remote(
      rtcEngine: engine,
      canvas: VideoCanvas(uid: remoteUid ?? 0),
      connection: const RtcConnection(channelId: ''),
    );
  }

  Future<void> joinChannel(String channel) async {
    await engine.joinChannel(
      token: null, // mode test
      channelId: channel,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  Future<void> leave() async {
    await engine.leaveChannel();
    await engine.release();
  }
}
