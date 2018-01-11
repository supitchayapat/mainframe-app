import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/src/dao/EventDao.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myapp/MFGlobals.dart' as global;

final StorageReference ref = FirebaseStorage.instance.ref();
final int ONE_MEGABYTE = 1024 * 1024;

class FileUtil {
  static Future loadImages() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    print("LOAD DIR: $dir");
    //if(global.imgFiles.isEmpty) {
      var list = await EventDao.getEvents();
      await Future.forEach(list, (evt) async {
        String fileName = evt.thumbnail.substring(evt.thumbnail.lastIndexOf("/") + 1);
        // ommit after params
        if(fileName.contains("?")) {
          fileName = fileName.substring(0, fileName.lastIndexOf("?"));
        }
        //print("Filename: $fileName");
        File imgFile = new File('$dir/$fileName');
        //print("File exists: ${await imgFile.exists()}");
        if(!(await imgFile.exists())) {
          StorageReference _imgRef = ref.child("event_images/$fileName");
          var _imgResult = await _imgRef.getData(ONE_MEGABYTE);
          //print("WRITING IMAGE FILE $fileName");
          await imgFile.writeAsBytes(_imgResult);
          //global.imgFiles.putIfAbsent(fileName, () => imgFile);
          /*String url = evt.thumbnail;
          http.get(Uri.parse(url)).then((res) {
            imgFile.writeAsBytes(res.bodyBytes);
          });*/
        }
      });
      //print("done for EACH!");
    //}
  }

  static Future<List> getImages() async {
    List<Widget> images = [];
    String dir = (await getApplicationDocumentsDirectory()).path;
    print(dir);
    await loadImages();
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