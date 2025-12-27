import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/config/agora_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';

class VideoCallPage extends StatefulWidget {
  final String channelName;
  final String appointmentId;
  final String userName;
  final bool isDoctor;

  const VideoCallPage({
    super.key,
    required this.channelName,
    required this.appointmentId,
    required this.userName,
    required this.isDoctor,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  late RtcEngine _engine;
  bool _localUserJoined = false;
  int? _remoteUid;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerEnabled = true;
  Timer? _callDurationTimer;
  int _callDurationSeconds = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAgora();
    _startCallDurationTimer();
    _updateAppointmentStatus('in_progress');
  }

  Future<void> _updateAppointmentStatus(String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .update({
            'status': status,
            if (status == 'in_progress')
              'callStartedAt': FieldValue.serverTimestamp(),
            if (status == 'completed')
              'callEndedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('❌ Erreur mise à jour statut: $e');
    }
  }

  void _startCallDurationTimer() {
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDurationSeconds++;
      });
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _initAgora() async {
    // Demander les permissions
    await [Permission.microphone, Permission.camera].request();

    // Créer le moteur Agora
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(
        appId: AgoraConfig.appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    // Configurer les événements
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('📞 Local user ${connection.localUid} joined');
          setState(() {
            _localUserJoined = true;
            _isLoading = false;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('📞 Remote user $remoteUid joined');
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint('📞 Remote user $remoteUid left channel');
              setState(() {
                _remoteUid = null;
              });
            },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
            '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token',
          );
        },
      ),
    );

    // Activer la vidéo
    await _engine.enableVideo();
    await _engine.startPreview();

    // Rejoindre le canal
    await _engine.joinChannel(
      token: '', // En production, générez un token sécurisé
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  Future<void> _toggleMute() async {
    setState(() {
      _isMuted = !_isMuted;
    });
    await _engine.muteLocalAudioStream(_isMuted);
  }

  Future<void> _toggleVideo() async {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    await _engine.muteLocalVideoStream(!_isVideoEnabled);
  }

  Future<void> _toggleSpeaker() async {
    setState(() {
      _isSpeakerEnabled = !_isSpeakerEnabled;
    });
    await _engine.setEnableSpeakerphone(_isSpeakerEnabled);
  }

  Future<void> _switchCamera() async {
    await _engine.switchCamera();
  }

  Future<void> _endCall() async {
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminer la consultation'),
        content: const Text(
          'Êtes-vous sûr de vouloir terminer cette consultation ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Terminer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldEnd == true) {
      await _updateAppointmentStatus('completed');
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _callDurationTimer?.cancel();
    _disposeAgora();
    super.dispose();
  }

  Future<void> _disposeAgora() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vue distante (plein écran)
          _remoteVideo(),

          // Vue locale (petit coin)
          Positioned(
            right: 16,
            top: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _localPreview(),
              ),
            ),
          ),

          // Header avec durée et nom
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    widget.userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: getProportionateScreenHeight(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDuration(_callDurationSeconds),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: getProportionateScreenHeight(14),
                    ),
                  ),
                  if (_remoteUid == null && !_isLoading) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'En attente de connexion...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: getProportionateScreenHeight(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Connexion en cours...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          // Contrôles en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: _isMuted
                        ? CupertinoIcons.mic_slash
                        : CupertinoIcons.mic,
                    label: _isMuted ? 'Muet' : 'Micro',
                    onPressed: _toggleMute,
                    isActive: !_isMuted,
                  ),
                  _buildControlButton(
                    icon: _isVideoEnabled
                        ? CupertinoIcons.videocam
                        : CupertinoIcons.videocam_fill,
                    label: _isVideoEnabled ? 'Vidéo' : 'Caméra off',
                    onPressed: _toggleVideo,
                    isActive: _isVideoEnabled,
                  ),
                  _buildControlButton(
                    icon: CupertinoIcons.camera_rotate,
                    label: 'Basculer',
                    onPressed: _switchCamera,
                    isActive: true,
                  ),
                  _buildControlButton(
                    icon: _isSpeakerEnabled
                        ? CupertinoIcons.speaker_2_fill
                        : CupertinoIcons.speaker_slash,
                    label: 'Haut-parleur',
                    onPressed: _toggleSpeaker,
                    isActive: _isSpeakerEnabled,
                  ),
                  _buildControlButton(
                    icon: CupertinoIcons.phone_down_fill,
                    label: 'Terminer',
                    onPressed: _endCall,
                    isActive: true,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isActive,
    Color? color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: EdgeInsets.all(getProportionateScreenWidth(16)),
              decoration: BoxDecoration(
                color:
                    color ??
                    (isActive
                        ? Colors.white.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2)),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: getProportionateScreenHeight(11),
          ),
        ),
      ],
    );
  }

  Widget _localPreview() {
    if (_localUserJoined) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      return Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(getProportionateScreenWidth(24)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isDoctor
                      ? CupertinoIcons.person
                      : CupertinoIcons.bag_badge_plus,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'En attente de l\'autre participant...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: getProportionateScreenHeight(18),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'La consultation débutera dès la connexion',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: getProportionateScreenHeight(14),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
