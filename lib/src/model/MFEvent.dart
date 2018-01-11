import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'EventDanceCategory.dart';
import 'EventLevel.dart';

class MFEvent {

  final formatterOut = new DateFormat("MMM dd");
  final formatterSrc = new DateFormat("yyyy-MM-dd");

  String eventTitle;
  String thumbnail;
  String thumbnailBg;
  String dateRange;
  bool hasAttended;
  int year;
  List<EventDanceCategory> danceCategories;
  List<EventLevel> levels;


  MFEvent({this.eventTitle, this.thumbnail, this.thumbnailBg, this.dateRange, this.year, this.hasAttended});

  /*MFEvent.fromSnapshot(var s)
      : eventTitle = s["eventTitle"],
        thumbnail = s["thumbnail"],
        thumbnailBg = s["thumbnailBg"],
        dateRange = s["dateRange"],
        hasAttended = (s["hasAttended"].toString().toLowerCase() == 'true') ? true : false,
        year = s["year"],
        danceCategories = (s["danceCategories"] as List).map((val) => val).toList();*/
  MFEvent.fromSnapshot(var s) {
    eventTitle = s["info"]["competitionName"];
    thumbnail = s["info"]["imgFilename"];
    thumbnailBg = s["info"]["thumbnailBg"];
    //dateRange = s["dateRange"];
    DateTime from = formatterSrc.parse(s["info"]["dateStart"]);
    DateTime to = formatterSrc.parse(s["info"]["dateStop"]);
    dateRange = "${formatterOut.format(from)} - ${formatterOut.format(to)}";
    hasAttended = (s["info"]["hasAttended"].toString().toLowerCase() == 'true') ? true : false;
    year = s["info"]["eventyear"];
    if(s["danceCategories"] != null) {
      danceCategories = (s["danceCategories"] as List).map((val) => new EventDanceCategory.fromSnapshot(val)).toList();
    } else {
      danceCategories = null;
    }
    
    if(s["levels"] != null) {
      levels = (s["levels"] as List).map((val) => new EventLevel.fromSnapshot(val)).toList();
    }
  }

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