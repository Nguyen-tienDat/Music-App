// In repository.dart
import '../model/song.dart';
import '../source/source.dart';

abstract class Repository {
  Future<List<Song>?> loadData();
  Future<List<Song>?> getSongsByArtist(String artist);
  Future<void> addSong(Song song);
  Future<void> updateSong(Song song);
  Future<void> deleteSong(String songId);
}

class DefaultRepository implements Repository {
  final FirestoreDataSource _dataSource = FirestoreDataSource();

  @override
  Future<List<Song>?> loadData() {
    return _dataSource.loadData();
  }

  @override
  Future<List<Song>?> getSongsByArtist(String artist) {
    return _dataSource.getSongsByArtist(artist);
  }

  @override
  Future<void> addSong(Song song) {
    return _dataSource.addSong(song);
  }

  @override
  Future<void> updateSong(Song song) {
    return _dataSource.updateSong(song);
  }

  @override
  Future<void> deleteSong(String songId) {
    return _dataSource.deleteSong(songId);
  }
}