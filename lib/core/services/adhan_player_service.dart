import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Plays the adhan from bundled assets (works fully offline).
///
/// The underlying player is created lazily so that merely building the UI
/// (or running widget tests) never touches the audio platform channel.
class AdhanPlayerService {
  static const String _adhanAsset = 'assets/audio/adhan.mp3';
  static const String _fajrAsset = 'assets/audio/adhan_fajr.mp3';

  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _subscription;

  /// `true` while the adhan is audible.
  final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);

  Future<void> play({required bool isFajr, required double volume}) async {
    try {
      final player = _player ??= AudioPlayer();

      _subscription ??= player.playerStateStream.listen((state) {
        isPlaying.value =
            state.playing && state.processingState != ProcessingState.completed;
      });

      await player.setAsset(isFajr ? _fajrAsset : _adhanAsset);
      await player.setVolume(volume.clamp(0.0, 1.0).toDouble());

      // play() only completes when playback ends, so it is not awaited.
      unawaited(player.play().catchError((Object e) {
        debugPrint('Adhan playback error: $e');
        isPlaying.value = false;
      }));
    } catch (e) {
      debugPrint('Unable to play adhan: $e');
      isPlaying.value = false;
    }
  }

  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (_) {}
    isPlaying.value = false;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _player?.dispose();
    isPlaying.dispose();
  }
}
