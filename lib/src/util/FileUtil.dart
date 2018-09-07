import 'dart:convert' show JSON;
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:myapp/src/dao/EventDao.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myapp/src/model/MFEvent.dart';

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
          try {
            var _imgResult = await _imgRef.getData(ONE_MEGABYTE);
            //print("WRITING IMAGE FILE $fileName");
            await imgFile.writeAsBytes(_imgResult);
          } catch(e) {
            print("ERROR WRITING $fileName");
            //MainFrameCrashReport.send("[File Util] ERROR WRITING IMAGE: ${evt.eventTitle}");
          }
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

  static Future downloadImagesCallback(Function p) async {
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
        try {
          var _imgResult = await _imgRef.getData(ONE_MEGABYTE);
          //print("WRITING IMAGE FILE $fileName");
          await imgFile.writeAsBytes(_imgResult);
          Function.apply(p, [fileName, imgFile]);
        } catch(e) {
          print("ERROR WRITING $fileName");
          print(e);
          //MainFrameCrashReport.send("[File Util] ERROR WRITING IMAGE: ${evt.eventTitle}");
        }
      } else {
        Function.apply(p, [fileName, imgFile]);
      }
    });
  }

  static Future<Map> getImages() async {
    Map<String, Widget> images = {};
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
          //images.add(img);
          images.putIfAbsent(fileName, () => img);
        }
      });
      print("return images [${images.length}]");
      return images;
    });
  }

  static Future<Widget> getImage(String fileName, {bool isDelete}) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    //String fileName = imageThumbnail.substring(imageThumbnail.lastIndexOf("/") + 1);
    File imgFile = new File('$dir/$fileName');
    bool isExist = await imgFile.exists();
    //print("$fileName File exists: $isExist");
    if(isExist) {
      if(isDelete) {
        imgFile.delete().then((val){
          print("Deleted $fileName");
        }).catchError((onError){
          print("cannot delete file $fileName. Error: ${onError}");
        });
        return null;
      }
      else {
        Widget item = new Image.file(imgFile);
        return item;
      }
    } else {
      if(isDelete) {
        print("cannot delete $fileName");
        return null;
      }
      return loadImage(fileName, imgFile);
    }
  }

  static Future<Widget> loadImage(fileName, imgFile) async {
    StorageReference _imgRef = ref.child("event_images/$fileName");
    try {
      var _imgResult = await _imgRef.getData(ONE_MEGABYTE);
      //print("WRITING IMAGE FILE $fileName");
      await imgFile.writeAsBytes(_imgResult);
      print("Downloaded image: $fileName");
      return new Image.file(imgFile);
    } catch(e) {
      print("ERROR WRITING $fileName");
      //MainFrameCrashReport.send("[File Util] ERROR WRITING IMAGE: ${evt.eventTitle}");
      return null;
    }
  }

  static Future<dynamic> getJson(fileName, {bool isDelete : false}) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    File jsonFile = new File('$dir/$fileName');
    bool isExist = await jsonFile.exists();
    if(isExist) {
      if(!isDelete) {
        List events = [];
        var result = JSON.decode(jsonFile.readAsStringSync());
        //MFEvent event = new MFEvent.fromJsonData(result);
        for(var evtItem in result){
          //print(evtItem);
          MFEvent event = new MFEvent.fromJsonData(evtItem);
          events.add(event);
        }
        return events;
      } else {
        jsonFile.delete().then((val){
          print("Deleted $fileName");
        }).catchError((onError){
          print("cannot delete file $fileName. Error: ${onError}");
        });
      }
    }
    print("json file does not exist..");
    return null;
  }

  static Future<dynamic> saveJson(fileName, events) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    File jsonFile = new File('$dir/$fileName');
    //bool isExist = await jsonFile.exists();
    //if(!isExist) {
      print("saving JSON file");
      //print(event.toJsonData().toString());
      jsonFile.writeAsStringSync(JSON.encode(events.map((val) => val?.toJsonData()).toList()));
      print("saved Json File");
    //}
    return null;
  }

  static Future cleanImages(events) async {
    List<FileSystemEntity> _files = (await getApplicationDocumentsDirectory()).listSync();
    List<FileSystemEntity> _forDelete = [];
    for(FileSystemEntity fileItm in _files){
      if(fileItm.path.indexOf(".png") > 0
          || fileItm.path.indexOf(".jpg") > 0
          || fileItm.path.indexOf(".jpeg") > 0) {
        print("FILEPATH: ${fileItm.path}");
        bool isFound = false;
        for(var event in events) {
          if(event.thumbnail != null && fileItm.path.contains(event.thumbnail)) {
            isFound = true;
          }
          if(event?.hotels != null) {
            for (var hotel in event.hotels) {
              if (hotel.imgFilename != null &&
                  fileItm.path.contains(hotel.imgFilename)) {
                isFound = true;
              }
            }
          }
        }
        if(!isFound) {
          _forDelete.add(fileItm);
        }
      }
    }

    _forDelete.forEach((del){
      print("DELETING ${del.path}");
      del.deleteSync();
    });
  }
}