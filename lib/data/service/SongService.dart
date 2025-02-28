import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/song.dart';


  //take all songs
Future<List<Song>> getSongs() async{
  final songCollection = FirebaseFirestore.instance.collection('songs');
  final snapshot = await songCollection.get();
  return snapshot.docs.map((doc) => Song.fromFirestore(doc)).toList();
}

//update listen count
Future<void> incrementCounter(String songId) async{
  final songDoc = FirebaseFirestore.instance.collection('songs').doc(songId);
  return songDoc.update({
    'counter' : FieldValue.increment(1)
  });
}
