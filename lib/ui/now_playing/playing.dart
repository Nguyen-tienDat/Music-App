import 'dart:convert';
import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/model/song.dart';
import 'audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(playingSong: playingSong, songs: songs);
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({
    super.key,
    required this.songs,
    required this.playingSong,
  });

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  //animation controller
  late AnimationController _imageAnimAController;
  late AudioPlayerManager _audioPlayerManager;
  late int _selectedItemIndex;
  late Song _song;
  double _currentAnimationPosition = 0.0;
  bool _isShuffle = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentAnimationPosition = 0.0;
    _song = widget.playingSong;
    _imageAnimAController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _audioPlayerManager =
        AudioPlayerManager(songUrl: widget.playingSong.source);
    _audioPlayerManager.init();
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
  }

  @override
  Widget build(BuildContext context) {
    final screenWith = MediaQuery.of(context).size.width;
    // lay do rong theo kich thuoc man hinh tru 64dp vien 2 ben
    const delta = 58;
    final radius = (screenWith - delta) / 2;
    // return const Scaffold(
    //     body: Center(
    //   child: Text('Now Playing'),
    // ));
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Now Playing'),
          trailing:
              IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ),
        child: Scaffold(
            body: Center(
          child: Column(
            //can vao giua
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_song.album),
              const SizedBox(
                height: 16,
              ),
              const Text('_ ___ _'),
              const SizedBox(
                height: 48,
              ),

              //tao ra dia xoay nhac
              RotationTransition(
                turns:
                    Tween(begin: 0.0, end: 0.5).animate(_imageAnimAController),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/itunes.jpg',
                    image: _song.image,
                    width: screenWith - delta,
                    height: screenWith - delta,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/itunes.jpg',
                        width: screenWith - delta,
                        height: screenWith - delta,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 64, bottom: 16),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.share_outlined),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Column(
                        children: [
                          Text(
                            _song.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            _song.artist,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.favorite_outline),
                        color: Theme.of(context).colorScheme.primary,
                      )
                    ],
                  ),
                ),
              ), //thanh cong cu
              Padding(
                padding: const EdgeInsets.only(
                    top: 32, left: 24, right: 24, bottom: 16),
                child: _progressBar(),
              ), //thanh phat nhac
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                ),
                child: _mediaButtons(),
              )
            ],
          ),
        )));
  }

  @override
  //huy bo bai hat hien dang phat neu chon 1 bai hat khac
  void dispose() {
    _audioPlayerManager.dispose();
    _imageAnimAController.dispose();
    super.dispose();
  }

  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
              function: _setShuffle,
              color: _getShuffleColor(),
              icon: Icons.shuffle,
              size: 24),
          MediaButtonControl(
              function: _setPrevSong,
              color: Colors.deepPurple,
              icon: Icons.skip_previous,
              size: 36),
          _playButton(),
          MediaButtonControl(
              function: _setNextSong,
              color: Colors.deepPurple,
              icon: Icons.skip_next,
              size: 36),
          MediaButtonControl(
              function: null,
              color: Colors.deepPurple,
              icon: Icons.repeat,
              size: 24),
        ],
      ),
    );
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationState,
        builder: (context, snapshot) {
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final buffered = durationState?.buffered ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;
          return ProgressBar(
            progress: progress,
            total: total,
            // lay bo dem
            buffered: buffered,
            //seekbar
            onSeek: _audioPlayerManager.player.seek,
            baseBarColor: Colors.black12,
            barHeight: 5.0,
            barCapShape: BarCapShape.round,
            progressBarColor: Colors.black,
            bufferedBarColor: Colors.grey.withOpacity(0.3),
            thumbColor: Colors.deepPurple,
            thumbGlowColor: Colors.grey.withOpacity(0.3),
          );
        });
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
        stream: _audioPlayerManager.player.playerStateStream,
        builder: (context, snapshot) {
          final playState = snapshot.data;
          final processingState = playState?.processingState;
          final playing = playState?.playing;

          if (processingState == ProcessingState.loading ||
              processingState == ProcessingState.buffering) {
            //pause animation
            //khi bai hat dang load => pause rotation
            _pauseRorationAnim();
            return Container(
              margin: const EdgeInsets.all(8),
              width: 48,
              height: 48,
              child: const CircularProgressIndicator(),
            );
          } else if (playing != true) {
            return MediaButtonControl(
                function: () {
                  // start or resume animation
                  _audioPlayerManager.player.play();
                },
                color: null,
                icon: Icons.play_arrow,
                size: 48);
          } else if (processingState != ProcessingState.completed) {
            //play animation
            _playRotationAnim();
            return MediaButtonControl(
                function: () {
                  // stop animation, save current position value for resume
                  _audioPlayerManager.player.pause();
                  _pauseRorationAnim();
                },
                color: null,
                icon: Icons.pause,
                size: 48);
          } else {
            // if song completed -> stop and reset animation
            if (processingState == ProcessingState.completed) {
              _stopRotationAnim();
              _resetRotationAnim();
            }

            return MediaButtonControl(
                function: () {
                  //reset and restart animation
                  _audioPlayerManager.player.seek(Duration.zero);
                  _resetRotationAnim();
                  _playRotationAnim();
                },
                color: null,
                icon: Icons.replay,
                size: 48);
          }
        });
  }

  //shuffle song
  void _setShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

  Color? _getShuffleColor() {
    return _isShuffle ? Colors.deepPurple : Colors.grey;
  }

  void _setNextSong() {
    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else {
      ++_selectedItemIndex;
    }
    if (_selectedItemIndex > widget.songs.length) {
      _selectedItemIndex = _selectedItemIndex % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    //reset animation
    _resetRotationAnim();
    setState(() {
      _song = nextSong;
    });
  }

//next-previous song
  void _setPrevSong() {
    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else {
      --_selectedItemIndex;
    }
    if (_selectedItemIndex < 0) {
      _selectedItemIndex = (-1 * _selectedItemIndex) % widget.songs.length;
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    //reset animation
    _resetRotationAnim();
    setState(() {
      _song = nextSong;
    });
  }

  //animation
  void _playRotationAnim() {
    _imageAnimAController.forward(from: _currentAnimationPosition);
    _imageAnimAController.repeat();
  }

  void _pauseRorationAnim() {
    _stopRotationAnim();
    _currentAnimationPosition = _imageAnimAController.value;
  }

  void _stopRotationAnim() {
    _imageAnimAController.stop();
  }

  void _resetRotationAnim() {
    _currentAnimationPosition = 0.0;
    _imageAnimAController.value = _currentAnimationPosition;
  }
}

class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.color,
    required this.icon,
    required this.size,
  });

  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  State<StatefulWidget> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
