import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  String id;
  String title;
  String album;
  String artist;
  String source;
  String image;
  int duration;
  bool favourite;
  int counter;
  int replay;
  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.source,
    required this.image,
    required this.duration,
    required this.favourite,
    required this.counter,
    required this.replay,
  });

  //create from JSON ( for RemoteDataSource and LocalDataSource)
  factory Song.fromJson(Map<String, dynamic> json){
    return Song(
        id: json['id'],
        title: json['title'],
        artist: json['artist'],
        album: json['album'],
        source: json['source'],
        image: json['image'],
        duration: json['duration'],
        favourite: json['favourite'] == 'true' ? true : false,
        counter: json['counter'],
        replay: json['replay']
    );
  }
//create from firestore
  factory Song.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Song(
      id: doc.id,
      title: data['title'] ?? '',
      album: data['album'] ?? '',
      artist: data['artist'] ?? '',
      source: data['source'] ?? '',
      image: data['image'] ?? '',
      duration: data['duration'] ?? 0,
      favourite: data['favourite'] ?? false,
      counter: data['counter'] ?? 0,
      replay: data['replay'] ?? 0,
    );
  }

  // redirect to JSON
Map<String, dynamic> toJson(){
    return{
      'id': id,
      'title': title,
      'album': album,
      'artist': artist,
      'source': source,
      'image': image,
      'duration': duration,
      'favourite': favourite.toString(),
      'counter': counter,
      'replay' : replay,
    };
  }
  // Add this method to your Song class
  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? source,
    String? image,
    int? duration,
    bool? favourite,
    int? counter,
    int? replay,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      source: source ?? this.source,
      image: image ?? this.image,
      duration: duration ?? this.duration,
      favourite: favourite ?? this.favourite,
      counter: counter ?? this.counter,
      replay: replay ?? this.replay,
    );
  }
}
