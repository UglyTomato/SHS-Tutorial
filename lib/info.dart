import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LastRoom {
  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    return File('$path/lastRoom.txt');
  }

  Future<String> readContent() async {
    try{
      final file = await localFile;
      String contents = await file.readAsString();
      print("this is the content:" + contents);
      return contents;
    }catch(e)
    {
      return '0';
    }
  }

  Future<File> writeContent(String content) async {
    final file = await localFile;
    print(file.path);
    return file.writeAsString('$content');
  }
}