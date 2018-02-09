import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'EventDanceCategory.dart';
import 'EventLevel.dart';
import 'FormEntry.dart';

class Venue {
  String venueName;
  String phone;
  String fax;
  String address;
  String address2;
  String city;
  String province;
  String country;
  String zip;
  String website;

  Venue({this.venueName, this.phone, this.fax, this.address, this.address2,
        this.city, this.province, this.country, this.zip, this.website});
}

class ContactInfo {
  String phone;
  String fax;
  String address;
  String address2;
  String city;
  String province;
  String country;
  String zip;
  String email;

  ContactInfo({this.phone, this.fax, this.address, this.address2,
    this.city, this.province, this.country, this.zip, this.email});
}

class MFEvent {

  final formatterOut = new DateFormat("MMM dd");
  final formatterSrc = new DateFormat("yyyy-MM-dd");

  String eventTitle;
  String thumbnail;
  String thumbnailBg;
  String dateRange;
  String statusName;
  DateTime startDate;
  DateTime stopDate;
  DateTime deadline;
  bool hasAttended;
  int year;
  Venue venue;
  ContactInfo contact;
  List<String> organizers;
  List<EventDanceCategory> danceCategories;
  List<EventLevel> levels;
  List<FormEntry> formEntries;

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
    eventTitle = s["info"]["name"];
    thumbnail = s["info"]["imgFilename"];
    thumbnailBg = s["info"]["thumbnailBg"];
    statusName = s["info"]["statusname"];
    //dateRange = s["dateRange"];
    startDate = formatterSrc.parse(s["info"]["dateStart"]);
    stopDate = formatterSrc.parse(s["info"]["dateStop"]);
    deadline = s["info"]["deadline"] != null ? formatterSrc.parse(s["info"]["deadline"]) : null;
    dateRange = "${formatterOut.format(startDate)} - ${formatterOut.format(stopDate)}";
    hasAttended = (s["info"]["hasAttended"].toString().toLowerCase() == 'true') ? true : false;
    year = s["info"]["eventyear"];

    // Venue
    this.venue = new Venue();
    venue.venueName = s["venue"]["name"] ?? "";
    venue.phone = s["venue"]["phone"] ?? "";
    venue.fax = s["venue"]["fax"] ?? "";
    venue.address = s["venue"]["address"] ?? "";
    venue.address2 = s["venue"]["address2"] ?? "";
    venue.city = s["venue"]["city"] ?? "";
    venue.province = s["venue"]["province"] ?? "";
    venue.country = s["venue"]["country"] ?? "";
    venue.zip = s["venue"]["zip"] ?? "";
    venue.website = s["venue"]["website"] ?? "";

    // Contact
    this.contact = new ContactInfo();
    contact.phone = s["contact"]["phone"] ?? "";
    contact.fax = s["contact"]["fax"] ?? "";
    contact.address = s["contact"]["address"] ?? "";
    contact.address2 = s["contact"]["address2"] ?? "";
    contact.city = s["contact"]["city"] ?? "";
    contact.province = s["contact"]["province"] ?? "";
    contact.country = s["contact"]["country"] ?? "";
    contact.zip = s["contact"]["zip"] ?? "";
    contact.email = s["contact"]["email"] ?? "";

    // Organizers
    this.organizers = [];
    var _orgs = s["organizers"];
    if(_orgs != null) {
      _orgs.forEach((itm){
        organizers.add(itm["name"]);
      });
    }

    if(s["danceCategories"] != null) {
      danceCategories = (s["danceCategories"] as List).map((val) => new EventDanceCategory.fromSnapshot(val)).toList();
    } else {
      danceCategories = null;
    }
    
    if(s["levels"] != null) {
      levels = (s["levels"] as List).map((val) => new EventLevel.fromSnapshot(val)).toList();
    }

    // form
    if(s["forms"] != null) {
      var _forms = s["forms"]["form"];
      formEntries = [];
      _forms.forEach((val){
        FormEntry entry = new FormEntry.fromSnapshot(val);
        formEntries.add(entry);
        formEntries.sort((a, b) => (a.order).compareTo(b.order));
        //print(entry.toJson());
      });
    }
  }

  toJson() {
    return {
      "eventTitle": eventTitle,
      "thumbnail": thumbnail,
      "thumbnailBg": thumbnailBg,
      "dateRange": dateRange,
      "hasAttended": hasAttended.toString(),
      "year": year.toString(),
    };
  }
}