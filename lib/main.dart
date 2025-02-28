import 'package:flutter/material.dart';
import 'package:zing_mp3/ui/home/home.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MusicApp());
}


//stless : ko can thay doi trang thai trong ban than: anh?, file word, ...
//stfull: thay doi lien tuc: bieu do,



