import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

final formatter = new DateFormat("yyyy-MM-dd HH:mm:ss");

class DeviceInfo {
  String id;
  String model;
  String version;
  String lastLogMessage;
  DateTime lastTimeStamp;
  List<DeviceLog> logs;

  DeviceInfo({this.id, this.model, this.version});

  DeviceInfo.fromSnapshot(DataSnapshot s) {
    id = s.value["id"];
    model = s.value["model"];
    version = s.value["version"];
    lastLogMessage = s.value["lastLogMessage"];
    if(s.value["lastTimeStamp"] != null) {
      lastTimeStamp = formatter.parse(s.value["lastTimeStamp"]);
    }
    if(s.value["logs"] != null) {
      var _logs = s.value["logs"];
      this.logs = [];
      _logs.forEach((itm){
        logs.add(new DeviceLog.fromSnapshot(itm));
      });
    }
  }

  toJson() {
    return {
      "id": id,
      "model": model,
      "version": version,
      "lastLogMessage": lastLogMessage,
      "lastTimeStamp": lastTimeStamp!= null ? formatter.format(lastTimeStamp) : formatter.format(new DateTime.now()),
      "logs": logs?.map((val) => val?.toJson())?.toList(),
    };
  }
}

class DeviceLog {

  String logMessage;
  DateTime timeStamp;

  DeviceLog({this.logMessage, this.timeStamp});

  DeviceLog.fromSnapshot(var s) {
    logMessage = s["logMessage"];
    if(s["timeStamp"] != null) {
      timeStamp = formatter.parse(s["timeStamp"]);
    }
  }

  toJson() {
    return {
      "logMessage": logMessage,
      "timeStamp": timeStamp!= null ? formatter.format(timeStamp) : formatter.format(new DateTime.now()),
    };
  }
}