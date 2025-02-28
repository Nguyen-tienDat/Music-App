import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/song.dart';

abstract interface class DataSource {
  Future<List<Song>?> loadData();
}

class FirestoreDataSource implements DataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'songs'; // Your collection name in Firestore

  @override
  Future<List<Song>?> loadData() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_collectionName).get();
      List<Song> songs = [];

      for (var doc in snapshot.docs) {
        try {
          songs.add(Song.fromFirestore(doc));
        } catch (e) {
          print('Error parsing song: $e');
          print('Problematic document ID: ${doc.id}');
        }
      }
      return songs;
    } catch (e) {
      print('Firestore request failed: $e');
      return null;
    }
  }

  // Add a song to Firestore
  Future<void> addSong(Song song) async {
    try {
      await _firestore.collection(_collectionName).add({
        'title': song.title,
        'artist': song.artist,
        'album': song.album,
        'source': song.source,
        'image': song.image,
        'duration': song.duration,
        'favourite': song.favourite,
        'counter': song.counter,
        'replay': song.replay,
      });
    } catch (e) {
      print('Error adding song: $e');
      throw e;
    }
  }

  // Update a song in Firestore
  Future<void> updateSong(Song song) async {
    try {
      await _firestore.collection(_collectionName).doc(song.id).update({
        'title': song.title,
        'artist': song.artist,
        'album': song.album,
        'source': song.source,
        'image': song.image,
        'duration': song.duration,
        'favourite': song.favourite,
        'counter': song.counter,
        'replay': song.replay,
      });
    } catch (e) {
      print('Error updating song: $e');
      throw e;
    }
  }

  // Delete a song from Firestore
  Future<void> deleteSong(String songId) async {
    try {
      await _firestore.collection(_collectionName).doc(songId).delete();
    } catch (e) {
      print('Error deleting song: $e');
      throw e;
    }
  }

  // Get songs by artist
  Future<List<Song>?> getSongsByArtist(String artist) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('artist', isEqualTo: artist)
          .get();

      List<Song> songs = [];
      for (var doc in snapshot.docs) {
        try {
          songs.add(Song.fromFirestore(doc));
        } catch (e) {
          print('Error parsing song: $e');
        }
      }
      return songs;
    } catch (e) {
      print('Firestore request failed: $e');
      return null;
    }
  }
}

// Keep this as a fallback if you still need local data access
class LocalDataSource implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    // Your existing local data source implementation
    // This can be kept as a fallback or for testing
    return [];
  }
}