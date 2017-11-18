
class EventLevel {
  String level;
  int order;

  EventLevel({this.level, this.order});

  EventLevel.fromSnapshot(var s) {
    level = s["level"];
    order = s["order"];
  }

  toJson() {
    return {
      "level": level,
      "order": order
    };
  }
}