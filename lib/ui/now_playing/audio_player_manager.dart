import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered, //bo dem xem dang load o dau
    this.total, // tong thoi luong bai hat
  });

  final Duration progress;
  final Duration buffered;
  final Duration? total;
}

class AudioPlayerManager {
  //tao lop singleton cho AudioPlayerManager
  AudioPlayerManager._internal();

  static final AudioPlayerManager _instance = AudioPlayerManager._internal();

  factory AudioPlayerManager() => _instance;

  final player = AudioPlayer();
  Stream<DurationState>? durationState;
  String songUrl = '';

  void prepare({bool isNewSong = false}) {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        player.positionStream,
        player.playbackEventStream,
        (position, playbackEvent) => DurationState(
            progress: position,
            buffered: playbackEvent.bufferedPosition,
            total: playbackEvent.duration));
    if (isNewSong) {
      player.setUrl(songUrl);
    }
  }

  void updateSongUrl(String url) {
    songUrl = url;
    prepare();
  }

  // sua loi phat chong lan bai hat
  void dispose() {
    player.dispose();
  }
}
