import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/config/app_config.dart';
import '../../../providers/storage_provider.dart';

class PlayerState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final String? title;
  final String? podcastTitle;
  final String? imageUrl;
  final String? audioUrl;
  final bool isRepeating;

  const PlayerState(
      {this.isPlaying = false,
      this.position = Duration.zero,
      this.duration = Duration.zero,
      this.title,
      this.podcastTitle,
      this.imageUrl,
      this.audioUrl,
      this.isRepeating = false});

  PlayerState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    String? title,
    String? podcastTitle,
    String? imageUrl,
    String? audioUrl,
    bool? isRepeating,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      title: title ?? this.title,
      podcastTitle: podcastTitle ?? this.podcastTitle,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      isRepeating: isRepeating ?? this.isRepeating,
    );
  }
}

final playerStateProvider = NotifierProvider<PlayerNotifier, PlayerState>(() {
  return PlayerNotifier();
});

class PlayerNotifier extends Notifier<PlayerState> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playerStateSub;
  Timer? _trackingTimer;

  @override
  PlayerState build() {
    _setupListeners();
    ref.onDispose(() {
      _cancelSubs();
      _stopTracking();
      _player.dispose();
    });
    return const PlayerState();
  }

  void _setupListeners() {
    _cancelSubs();
    _positionSub = _player.positionStream.listen((p) {
      state = state.copyWith(position: p);
    });
    _durationSub = _player.durationStream.listen((d) {
      state = state.copyWith(duration: d ?? Duration.zero);
    });
    _playerStateSub = _player.playerStateStream.listen((ps) {
      state = state.copyWith(isPlaying: ps.playing);
      _updateNotification();

      if (ps.playing) {
        _startTracking();
      } else {
        _stopTracking();
      }

      if (ps.processingState == ProcessingState.completed) {
        _onEpisodeCompleted();
      }
    });
  }

  void _cancelSubs() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
  }

  void _startTracking() {
    _stopTracking();
    _trackingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final storage = ref.read(storageServiceProvider);
      storage.addListeningTime(
        5,
        state.podcastTitle ?? 'Unknown',
        state.imageUrl,
      );
      storage.addMonthlyListeningTime(5);
    });
  }

  void _stopTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
  }

  void _onEpisodeCompleted() async {
    final storage = ref.read(storageServiceProvider);
    await storage.incrementEpisodesCompleted();
  }

  Future<void> _updateNotification() async {
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke('updateNotification', {
        'title': state.title ?? '',
        'podcastTitle': state.podcastTitle ?? '',
        'isPlaying': state.isPlaying,
      });
    }
  }

  Future<void> play({
    required String url,
    required String title,
    required String podcastTitle,
    String? imageUrl,
  }) async {
    state = PlayerState(
      title: title,
      podcastTitle: podcastTitle,
      imageUrl: imageUrl,
      audioUrl: url,
    );

    // Save to recently played
    final storage = ref.read(storageServiceProvider);
    await storage.addRecentlyPlayed({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'podcastTitle': podcastTitle,
      'image': imageUrl ?? '',
      'audio': url,
      'playedAt': DateTime.now().toIso8601String(),
    });

    final service = FlutterBackgroundService();
    if (!await service.isRunning()) {
      await service.startService();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          headers: {
            'X-ListenAPI-Key': AppConfig.listenNotesApiKey,
          },
        ),
      );
      await _player.play();
      _updateNotification();
    } catch (e) {
      try {
        await _player.setUrl(url);
        await _player.play();
        _updateNotification();
      } catch (e2) {
        // ignore
      }
    }
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    state = state.copyWith(position: position);
  }

  Future<void> stop() async {
    _stopTracking();
    await _player.stop();
    FlutterBackgroundService().invoke('stopService');
    state = const PlayerState();
  }

  void toggleRepeat() {
    final newRepeat = !state.isRepeating;
    state = state.copyWith(isRepeating: newRepeat);
    _player.setLoopMode(newRepeat ? LoopMode.one : LoopMode.off);
  }
}
