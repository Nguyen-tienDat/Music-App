import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zing_mp3/ui/home/viewmodel.dart';
import 'package:zing_mp3/ui/now_playing/audio_player_manager.dart';

import '../../data/model/song.dart';
import '../discovery/discovery.dart';
import '../now_playing/playing.dart';
import '../settings/Settings.dart';
import '../user/user.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Zing MP3",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const AccountTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Zing MP3'),
      ),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
            backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.album), label: 'Discover'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Account'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: 'Settings'),
            ]),
        tabBuilder: (BuildContext context, int index) {
          return _tabs[index];
        },
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  late MusicAppViewModel _viewModel;
  bool _isLoading = true;
  List<Song> _songs = [];

  @override
  void initState() {
    super.initState();
    _viewModel = MusicAppViewModel();
    _initData();
  }

  Future<void> _initData() async {
    // Listen to song stream
    _viewModel.songStream.listen((songList) {
      setState(() {
        _songs = songList;
        _isLoading = false;
      });
    }, onError: (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(error.toString());
    });

    // Load songs
    await _viewModel.loadSongs();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _refreshSongs(),
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _getBody() {
    if (_isLoading) {
      return _getProgressBar();
    } else if (_songs.isEmpty) {
      return _getEmptyState();
    } else {
      return _getListView();
    }
  }

  Widget _getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _getEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No songs found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _refreshSongs(),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  ListView _getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return _getRow(position);
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      },
      itemCount: _songs.length,
      shrinkWrap: true,
    );
  }

  Widget _getRow(int index) {
    return _SongItemSection(
      parent: this,
      song: _songs[index],
      onFavoriteToggle: _toggleFavorite,
    );
  }

  Future<void> _refreshSongs() async {
    setState(() {
      _isLoading = true;
    });
    await _viewModel.loadSongs();
  }

  Future<void> _toggleFavorite(Song song) async {
    await _viewModel.toggleFavorite(song);
  }

  void showSongOptions(Song song) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                  height: 300,
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            song.image,
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset('assets/itunes.jpg', width: 40, height: 40);
                            },
                          ),
                        ),
                        title: Text(song.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(song.artist),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.playlist_add),
                        title: const Text('Add to playlist'),
                        onTap: () {
                          Navigator.pop(context);
                          // Add playlist functionality here
                        },
                      ),
                      ListTile(
                        leading: Icon(song.favourite ? Icons.favorite : Icons.favorite_border),
                        title: Text(song.favourite ? 'Remove from favorites' : 'Add to favorites'),
                        onTap: () {
                          _toggleFavorite(song);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.share),
                        title: const Text('Share'),
                        onTap: () {
                          Navigator.pop(context);
                          // Share functionality here
                        },
                      ),
                    ],
                  )));
        });
  }

  void navigate(Song song) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return NowPlaying(
        songs: _songs,
        playingSong: song,
      );
    }));
  }

  @override
  void dispose() {
    _viewModel.dispose();
    AudioPlayerManager().dispose();
    super.dispose();
  }
}

class _SongItemSection extends StatelessWidget {
  const _SongItemSection({
    required this.parent,
    required this.song,
    required this.onFavoriteToggle,
  });

  final _HomeTabPageState parent;
  final Song song;
  final Function(Song) onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: 24,
        right: 8,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/itunes.jpg',
          image: song.image,
          width: 48,
          height: 48,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/itunes.jpg', width: 48, height: 48);
          },
        ),
      ),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              song.favourite ? Icons.favorite : Icons.favorite_border,
              color: song.favourite ? Colors.red : null,
            ),
            onPressed: () => onFavoriteToggle(song),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              parent.showSongOptions(song);
            },
          ),
        ],
      ),
      onTap: () {
        parent.navigate(song);
      },
    );
  }
}