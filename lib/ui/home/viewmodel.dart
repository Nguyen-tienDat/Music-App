import 'dart:async';
import 'package:zing_mp3/data/model/song.dart';
import 'package:zing_mp3/data/repository/repository.dart';

class MusicAppViewModel {
  final Repository _repository; // Define repository interface
  final StreamController<List<Song>> _songStreamController = StreamController<List<Song>>.broadcast();

  // Expose stream for UI to listen to
  Stream<List<Song>> get songStream => _songStreamController.stream;

  // Constructor with dependency injection
  MusicAppViewModel({Repository? repository})
      : _repository = repository ?? DefaultRepository();

  // Load songs from repository
  Future<void> loadSongs() async {
    try {
      final songs = await _repository.loadData();
      if (songs != null) {
        _songStreamController.add(songs);
      } else {
        // Handle null case
        _songStreamController.add([]);
      }
    } catch (e) {
      // Handle errors properly
      print('Error loading songs: $e');
      _songStreamController.addError(e);
    }
  }

  // Add a method to filter songs by artist
  Future<void> filterSongsByArtist(String artist) async {
    try {
      final songs = await _repository.getSongsByArtist(artist);
      if (songs != null) {
        _songStreamController.add(songs);
      }
    } catch (e) {
      print('Error filtering songs: $e');
      _songStreamController.addError(e);
    }
  }

  // Method to add a new song
  Future<void> addSong(Song song) async {
    try {
      await _repository.addSong(song);
      await loadSongs(); // Reload the songs after adding
    } catch (e) {
      print('Error adding song: $e');
      _songStreamController.addError(e);
    }
  }

  // Method to update a song
  Future<void> updateSong(Song song) async {
    try {
      await _repository.updateSong(song);
      await loadSongs(); // Reload the songs after updating
    } catch (e) {
      print('Error updating song: $e');
      _songStreamController.addError(e);
    }
  }

  // Method to toggle favorite status
  Future<void> toggleFavorite(Song song) async {
    try {
      final updatedSong = song.copyWith(favourite: !song.favourite);
      await _repository.updateSong(updatedSong);
      await loadSongs();
    } catch (e) {
      print('Error toggling favorite: $e');
      _songStreamController.addError(e);
    }
  }

  // Clean up resources when done
  void dispose() {
    _songStreamController.close();
  }
}