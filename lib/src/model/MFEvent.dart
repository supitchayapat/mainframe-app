import 'package:firebase_database/firebase_database.dart';

class MFEvent {

  String eventTitle;
  String thumbnail;
  String thumbnailBg;
  String dateRange;
  bool hasAttended;
  int year;

  MFEvent({this.eventTitle, this.thumbnail, this.thumbnailBg, this.dateRange, this.year, this.hasAttended});

  MFEvent.fromSnapshot(var s)
      : eventTitle = s["eventTitle"],
        thumbnail = s["thumbnail"],
        thumbnailBg = s["thumbnailBg"],
        dateRange = s["dateRange"],
        hasAttended = (s["hasAttended"].toString().toLowerCase() == 'true') ? true : false,
        year = s["year"];

  toJson() {
    return {
      "eventTitle": eventTitle,
      "thumbnail": thumbnail,
      "thumbnailBg": thumbnailBg,
      "dateRange": dateRange,
      "hasAttended": hasAttended.toString(),
      "year": year.toString()
    };
  }
}