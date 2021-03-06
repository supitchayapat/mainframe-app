import 'package:intl/intl.dart';
import 'EventDanceCategory.dart';
import 'EventLevel.dart';
import 'FormEntry.dart';
import 'MFResult.dart';
import 'TicketConfig.dart';

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

  ContactInfo.fromSnapshot(var s) {
    phone = s["phone"];
    fax = s["fax"];
    address = s["address"];
    address2 = s["address2"];
    city = s["city"];
    province = s["province"];
    country = s["country"];
    zip = s["zip"];
    email = s["email"];
  }

  toJson() {
    return {
      "phone": phone,
      "fax": fax,
      "address": address,
      "address2": address2,
      "city": city,
      "province": province,
      "country": country,
      "zip": zip,
      "email": email
    };
  }
}

class TimeData {
  String description;
  String timeValue;
  int tvalOrder;

  TimeData({this.description, this.timeValue, this.tvalOrder});

  TimeData.fromSnapshot(var s) {
    description = s["description"];
    timeValue = s["timeValue"];
    tvalOrder = s["tvalOrder"];
  }

  toJson() {
    return {
      "description": description,
      "timeValue": timeValue,
      "tvalOrder": tvalOrder,
    };
  }
}

class Schedule {
  int hdrOrder;
  String headerName;
  List<TimeData> timedata;

  Schedule({this.hdrOrder, this.headerName, this.timedata});

  Schedule.fromSnapshot(var s) {
    hdrOrder = s["hdrOrder"];
    headerName = s["headerName"];
    if(s["timedata"] != null && s["timedata"].length > 0) {
      timedata = [];
      for(var _timeData in s["timedata"]) {
        timedata.add(new TimeData.fromSnapshot(_timeData));
      }
    }
  }

  toJson() {
    return {
      "hdrOrder": hdrOrder,
      "headerName": headerName,
      "timedata": timedata?.map((val) => val?.toJson())?.toList(),
    };
  }
}

class HotInfoSponsor {
  String description;
  String url;
  String imgFilename; // missing imageUrl child
  int orderValue;

  HotInfoSponsor({this.description, this.url, this.imgFilename, this.orderValue});

  HotInfoSponsor.fromSnapshot(var s) {
    description = s["description"];
    url = s["url"];
    orderValue = s["orderValue"];
    imgFilename = s["imgFilename"];
  }

  toJson() {
    return {
      "description": description,
      "url": url,
      "orderValue": orderValue
    };
  }
}

class EventSchedule {
  int id;
  String title;
  List<Schedule> schedules;

  EventSchedule({this.id, this.title, this.schedules});
  
  EventSchedule.fromSnapshot(var s) {
    id = s["id"];
    title = s["title"];
    if(s["schedules"] != null && s["schedules"].length > 0) {
      schedules = [];
      for(var _schedule in s["schedules"]) {
        schedules.add(new Schedule.fromSnapshot(_schedule));
      }
    }
  }

  toJson() {
    return {
      "id": id,
      "title": title,
      "schedules": schedules?.map((val) => val?.toJson())?.toList(),
    };
  }
}

class Finance {
  String description;
  String id;
  double surcharge;

  Finance({this.description, this.id, this.surcharge});

  Finance.fromSnapshot(var s) {
    description = s["description"];
    id = (s["id"]).toString();
    surcharge = (s["surcharge"])?.toDouble();
  }

  toJson() {
    return {
      "description": description,
      "id": id,
      "surcharge": surcharge,
    };
  }
}

class MFEvent {

  final formatterOut = new DateFormat("MMM d");
  final formatterSrc = new DateFormat("yyyy-MM-dd");

  String id;
  String evtPId;
  String eventTitle;
  String thumbnail;
  String thumbnailBg;
  String dateRange;
  String statusName;
  DateTime dateStart;
  DateTime dateStop;
  DateTime deadline;
  bool hasAttended;
  bool testEvent;
  int year;
  String website;
  bool uberRegister;
  bool websiteEnabled;
  MFResult results;
  Venue venue;
  ContactInfo contact;
  Finance finance;
  List<String> organizers;
  List<HotInfoSponsor> hotels;
  List<HotInfoSponsor> informations;
  List<HotInfoSponsor> sponsors;
  List<EventDanceCategory> danceCategories;
  List<EventLevel> levels;
  List<FormEntry> formEntries;
  Admission admission;
  TicketConfig ticketConfig;

  EventSchedule schedule;

  MFEvent({this.id, this.evtPId, this.eventTitle, this.thumbnail, this.thumbnailBg, this.dateRange, this.year, this.hasAttended});

  /*MFEvent.fromSnapshot(var s)
      : eventTitle = s["eventTitle"],
        thumbnail = s["thumbnail"],
        thumbnailBg = s["thumbnailBg"],
        dateRange = s["dateRange"],
        hasAttended = (s["hasAttended"].toString().toLowerCase() == 'true') ? true : false,
        year = s["year"],
        danceCategories = (s["danceCategories"] as List).map((val) => val).toList();*/
  MFEvent.userSnapshot(var s) {
    id = (s["info"]["id"]).toString();
    eventTitle = s["info"]["eventTitle"];
    thumbnail = s["info"]["thumbnail"];
    thumbnailBg = s["info"]["thumbnailBg"];
    if(s["info"]["dateStart"] != null)
      dateStart = formatterSrc.parse(s["info"]["dateStart"]);
    if(s["info"]["dateStop"] != null)
      dateStop = formatterSrc.parse(s["info"]["dateStop"]);
    deadline = s["info"]["deadline"] != null ? formatterSrc.parse(s["info"]["deadline"]) : null;
    if(dateStart == dateStop) {
      dateRange = "${formatterOut.format(dateStart)}";
    } else if(dateStart != null && dateStop != null) {
      dateRange = "${formatterOut.format(dateStart)} - ${formatterOut.format(dateStop)}";
    }
    hasAttended = (s["info"]["hasAttended"].toString().toLowerCase() == 'true') ? true : false;
    testEvent = (s["info"]["testEvent"].toString().toLowerCase() == 'true') ? true : false;
    year = int.parse(s["info"]["year"]);
    website = s["info"]["website"] ?? "";
    uberRegister = s["info"]["uberRegister"];
    websiteEnabled = s["info"]["websiteEnabled"];

    // Contact
    if(s["contact"] != null) {
      this.contact = new ContactInfo();
      contact.phone = s["contact"]["phone"] ?? "";
      contact.fax = s["contact"]["fax"] ?? "";
      contact.address = s["contact"]["address"] ?? "";
      contact.address2 = s["contact"]["address2"] ?? "";
      contact.city = s["contact"]["city"] ?? "";
      contact.province = s["contact"]["province"] ?? "";
      contact.country = s["contact"]["country"] ?? "";
      contact.zip = s["contact"]["zipcode"] ?? "";
      contact.email = s["contact"]["email"] ?? "";
    }

    // Organizers
    var _orgs = s["organizers"];
    if(_orgs != null) {
      this.organizers = [];
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
      var _admission = s["forms"]["admission"];
      var _ticketConfig = s["forms"]["ticket_config"];
      if(_forms != null) {
        formEntries = [];
        if(_forms is List) {
          _forms.forEach((val) {
            FormEntry entry = new FormEntry.fromSnapshot(val);
            formEntries.add(entry);
            formEntries.sort((a, b) => (a.order).compareTo(b.order));
            print(entry.toJson());
          });
        } else {
          FormEntry entry = new FormEntry.fromSnapshot(_forms);
          formEntries.add(entry);
        }
      }
      if(_admission != null) {
        admission = new Admission.fromSnapshot(_admission);
        //print(admission.toJson());
      }
      if(_ticketConfig != null) {
        ticketConfig = new TicketConfig.fromSnapshot(_ticketConfig);
        //print(admission.toJson());
      }
    }

    if(s["schedule"] != null) {
      schedule = new EventSchedule.fromSnapshot(s["schedule"]);
      //print(schedule.toJson());
    }

    if(s["finance"] != null) {
      finance = new Finance.fromSnapshot(s["finance"]);
      //print(finance?.toJson());
    }

    if(s["results"] != null) {
      results = new MFResult.fromSnapshot(s["results"]);
    }
  }

  MFEvent.fromSnapshot(var s) {
    id = (s["info"]["id"]).toString();
    eventTitle = s["info"]["name"];
    thumbnail = s["info"]["imgFilename"];
    thumbnailBg = s["info"]["thumbnailBg"];
    statusName = s["info"]["statusname"];
    //dateRange = s["dateRange"];
    //print("DATESTART: ${s["info"]["dateStart"]}");
    dateStart = formatterSrc.parse(s["info"]["dateStart"]);
    dateStop = formatterSrc.parse(s["info"]["dateStop"]);
    deadline = s["info"]["deadline"] != null ? formatterSrc.parse(s["info"]["deadline"]) : null;
    if(dateStart == dateStop) {
      dateRange = "${formatterOut.format(dateStart)}";
    } else {
      dateRange = "${formatterOut.format(dateStart)} - ${formatterOut.format(dateStop)}";
    }
    hasAttended = (s["info"]["hasAttended"].toString().toLowerCase() == 'true') ? true : false;
    testEvent = (s["info"]["testEvent"].toString().toLowerCase() == 'true') ? true : false;
    year = s["info"]["eventyear"];
    website = s["info"]["website"] ?? "";
    uberRegister = s["info"]["uberRegister"];
    websiteEnabled = s["info"]["websiteEnabled"];

    // Venue
    if(s["venue"] != null) {
      this.venue = new Venue();
      venue.venueName = s["venue"]["name"] ?? "";
      venue.phone = s["venue"]["phone"] ?? "";
      venue.fax = s["venue"]["fax"] ?? "";
      venue.address = s["venue"]["address"] ?? "";
      venue.address2 = s["venue"]["address2"] ?? "";
      venue.city = s["venue"]["city"] ?? "";
      venue.province = s["venue"]["province"] ?? "";
      venue.country = s["venue"]["country"] ?? "";
      venue.zip = s["venue"]["zipcode"] ?? "";
      venue.website = s["venue"]["website"] ?? "";
    }

    // Contact
    if(s["contact"] != null) {
      this.contact = new ContactInfo();
      contact.phone = s["contact"]["phone"] ?? "";
      contact.fax = s["contact"]["fax"] ?? "";
      contact.address = s["contact"]["address"] ?? "";
      contact.address2 = s["contact"]["address2"] ?? "";
      contact.city = s["contact"]["city"] ?? "";
      contact.province = s["contact"]["province"] ?? "";
      contact.country = s["contact"]["country"] ?? "";
      contact.zip = s["contact"]["zipcode"] ?? "";
      contact.email = s["contact"]["email"] ?? "";
    }

    // Organizers
    var _orgs = s["organizers"];
    if(_orgs != null) {
      this.organizers = [];
      _orgs.forEach((itm){
        organizers.add(itm["name"]);
      });
    }

    // Hotels
    if(s["hotels"] != null) {
      var _hotels = s["hotels"];
      this.hotels = [];
      _hotels.forEach((itm){
        hotels.add(new HotInfoSponsor.fromSnapshot(itm));
      });
    }

    // Informations
    if(s["informations"] != null) {
      var _infos = s["informations"];
      this.informations = [];
      _infos.forEach((itm){
        informations.add(new HotInfoSponsor.fromSnapshot(itm));
      });
    }

    // Sponsors
    if(s["sponsors"] != null) {
      var _sponsors = s["sponsors"];
      this.sponsors = [];
      _sponsors.forEach((itm){
        sponsors.add(new HotInfoSponsor.fromSnapshot(itm));
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
      var _admission = s["forms"]["admission"];
      var _ticketConfig = s["forms"]["ticket_config"];
      if(_forms != null) {
        formEntries = [];
        if(_forms is List) {
          _forms.forEach((val) {
            FormEntry entry = new FormEntry.fromSnapshot(val);
            formEntries.add(entry);
            formEntries.sort((a, b) => (a.order).compareTo(b.order));
            print(entry.toJson());
          });
        } else {
          FormEntry entry = new FormEntry.fromSnapshot(_forms);
          formEntries.add(entry);
        }
      }
      if(_admission != null) {
        admission = new Admission.fromSnapshot(_admission);
        //print(admission.toJson());
      }
      if(_ticketConfig != null) {
        ticketConfig = new TicketConfig.fromSnapshot(_ticketConfig);
      }
    }

    if(s["schedule"] != null) {
      schedule = new EventSchedule.fromSnapshot(s["schedule"]);
      //print(schedule.toJson());
    }

    if(s["finance"] != null) {
      finance = new Finance.fromSnapshot(s["finance"]);
      //print(finance?.toJson());
    }

    if(s["results"] != null) {
      results = new MFResult.fromSnapshot(s["results"]);
    }
  }

  MFEvent.fromJsonData(var s) {
    id = (s["id"]).toString();
    eventTitle = s["eventTitle"];
    thumbnail = s["imgFilename"];
    thumbnailBg = s["thumbnailBg"];
    // Hotels
    if(s["hotels"] != null) {
      var _hotels = s["hotels"];
      this.hotels = [];
      _hotels.forEach((itm){
        hotels.add(new HotInfoSponsor.fromSnapshot(itm));
      });
    }
  }

  MFEvent.fromSnapshotEntry(var s) {
    //print(s);
    id = (s["id"]).toString();
    eventTitle = s["eventTitle"];
    thumbnail = s["imgFilename"];
    thumbnailBg = s["thumbnailBg"];
    statusName = s["statusName"];
    //dateRange = s["dateRange"];
    dateStart = s["dateStart"] != null ? formatterSrc.parse(s["dateStart"]) : null;
    dateStop = s["dateStop"] != null ? formatterSrc.parse(s["dateStop"]) : null;
    deadline = s["deadline"] != null ? formatterSrc.parse(s["deadline"]) : null;
    if(dateStart != null && dateStop != null) {
      dateRange = "${formatterOut.format(dateStart)} - ${formatterOut.format(dateStop)}";
    }
    hasAttended = (s["hasAttended"]?.toString()?.toLowerCase() == 'true') ? true : false;
    year = s["eventyear"];
    if(s["contact"] != null) {
      contact = new ContactInfo.fromSnapshot(s["contact"]);
    }
  }

  toJson() {
    return {
      "id": id,
      "eventTitle": eventTitle,
      "thumbnail": thumbnail,
      "thumbnailBg": thumbnailBg,
      "dateStart": dateStart!= null ? formatterSrc.format(dateStart) : formatterSrc.format(new DateTime.now()),
      "stopDate": dateStop!= null ? formatterSrc.format(dateStop) : formatterSrc.format(new DateTime.now()),
      "deadline": deadline!= null ? formatterSrc.format(deadline) : formatterSrc.format(new DateTime.now()),
      "dateRange": dateRange,
      "hasAttended": hasAttended.toString(),
      "contact": contact?.toJson(),
      "year": year.toString(),
    };
  }

  toJsonData() {
    return {
      "id": id,
      "eventTitle": eventTitle,
      "thumbnail": thumbnail,
      "thumbnailBg": thumbnailBg,
      "hotels": hotels?.map((val) => val?.toJson())?.toList(),
    };
  }
}