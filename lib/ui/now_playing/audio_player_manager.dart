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
  AudioPlayerManager({required this.songUrl});

  final player = AudioPlayer();
  Stream<DurationState>? durationState;
  String songUrl;

  void init() {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        player.positionStream,
        player.playbackEventStream,
        (position, playbackEvent) => DurationState(
            progress: position,
            buffered: playbackEvent.bufferedPosition,
            total: playbackEvent.duration));
    player.setUrl(songUrl);
  }

  void updateSongUrl(String url){
    songUrl = url;
    init();
  }
  // sua loi phat chong lan bai hat
  void dispose(){
    player.dispose();
  }
}
