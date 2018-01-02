import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/src/dao/EventDao.dart';
import 'package:flutter/material.dart';

class FileUtil {
  static Future loadImages() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    print(dir);
    EventDao.getEvents().then((list){
      list.forEach((evt) async {
        String fileName = evt.thumbnail.substring(evt.thumbnail.lastIndexOf("/") + 1);
        //print("Filename: $fileName");
        File imgFile = new File('$dir/$fileName');
        //print("File exists: ${await imgFile.exists()}");
        if(!(await imgFile.exists())) {
          String url = evt.thumbnail;
          http.get(Uri.parse(url)).then((res) {
            imgFile.writeAsBytes(res.bodyBytes);
          });
        }
      });
    });
  }

  static Future<List> getImages() async {
    List<Widget> images = [];
    String dir = (await getApplicationDocumentsDirectory()).path;
    print(dir);
    return EventDao.getEvents().then((list) async {
      await Future.forEach(list, (evt) async {
        String fileName = evt.thumbnail.substring(evt.thumbnail.lastIndexOf("/") + 1);
        File imgFile = new File('$dir/$fileName');
        bool isExist = await imgFile.exists();
        if(isExist) {
          Image img = new Image.file(imgFile);
          images.add(img);
        }
      });
      print("return images [${images.length}]");
      return images;
    });
  }

  static Future<Widget> getImage(String imageThumbnail) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    String fileName = imageThumbnail.substring(imageThumbnail.lastIndexOf("/") + 1);
    File imgFile = new File('$dir/$fileName');
    bool isExist = await imgFile.exists();
    //print("$fileName File exists: $isExist");
    if(isExist) {
      Widget item = new Image.file(imgFile);
      return item;
    } else {
      return null;
    }
  }
}